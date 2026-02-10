class MetricsController < ApplicationController
  include ActionController::Live

  def stream
    # 1. Set the correct headers for SSE
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Connection'] = 'keep-alive'

    # 2. Open the 'Event stream'
    sse = SSE.new(response.stream, event: "metric_update")

    begin
      subscriber = ActiveSupport::Notifications.subscribe("metric_saved") do |_name, _start, _finish, _id, payload|
        begin
          # 🛡️ THE PROTECTION: Wrap write in a rescue
          sse.write({
            timestamp: payload["created_at"],
            cpu_usage_percent: payload["cpu_usage_percent"],
            memory_usage_percent: payload["memory_usage_percent"],
            network_in_kb: payload["network_in_kb"],
            network_out_kb: payload["network_out_kb"]
          })
        rescue ActionController::Live::ClientDisconnected
          # If the client is gone, we simply stop writing.
          # This prevents the error from bubbling up and killing the background job!
        end
      end

      # Keep the connection open
      sleep
    rescue IOError, ActionController::Live::ClientDisconnected
      Rails.logger.info "Metrics SSE disconnected"
    ensure
      # 🧹 Cleanup
      ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
      sse.close
    end
  end

  def simulate_spike
    # Check if simulation is already running
    if Rails.cache.read("simulation_active")
      render json: { error: "Simulation is already running. Please wait for it to finish." }, status: :conflict
      return
    end
    
    # We call a private method to check if the data sent is safe.
    errors = validate_simulation_params(params)
    if errors.any?
      render json: { errors: errors }, status: :bad_request
      return
    end

    # IMMEDIATELY TURN ON THE LOCK
    Rails.cache.write("simulation_active", true)

    last_metric = Metric.last
    baseline = {
      "cpu_usage_percent" => last_metric&.cpu_usage_percent,
      "memory_usage_percent" => last_metric&.memory_usage_percent,
      "network_in_kb" => last_metric&.network_in_kb,
      "network_out_kb" => last_metric&.network_out_kb
    }
    
    spike_data = params.permit(:cpu_usage_percent, :memory_usage_percent, :network_in_kb, :network_out_kb)
                      .to_h.compact.transform_values(&:to_f)
    
    final_params = baseline.merge(spike_data.stringify_keys)
    duration = (params[:duration_seconds] || 5).to_i # Default to 5 seconds if not sent

    # 2. THE BACKGROUND THREAD
    # We use Thread.new to do the "hard work" while the API replies instantly.
    Thread.new do
      begin
        end_time = Time.now + duration
        while Time.now < end_time
          IngestMetricService.new(final_params).execute
          sleep 2 
        end
      ensure
        # 2. TURN OFF THE LOCK
        Rails.cache.delete("simulation_active")
        puts "📈 Simulation Complete. Real collection resumed."
      end
    end

    # 3. REPLY INSTANTLY
    render json: { 
      message: "Simulation started for #{duration} seconds", 
      spiking_data: spike_data 
    }
  end

  def validate_simulation_params(p)
    errors = []

    # for cpu and mem
    [:cpu_usage_percent, :memory_usage_percent].each do |key|
      if p[key].present?
        val = p[key].to_f
        errors << "#{key.to_s.humanize} must be between 0 and 100" if val < 0 || val > 100
      end
    end

    # for network
    [:network_in_kb, :network_out_kb].each do |key|
      if p[key].present?
        val = p[key].to_f
        errors << "#{key.to_s.humanize} cannot be negative" if val < 0
      end
    end

    # for duration 
    if [:duration_seconds].present?
      duration = p[:duration_seconds].to_i
      errors << "Duration must be between 1 and 120 seconds" if duration < 1 || duration > 120
    end

    errors
  end
end