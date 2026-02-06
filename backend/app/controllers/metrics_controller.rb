class MetricsController < ApplicationController
  include ActionController::Live

  def stream
    # 1. Set the correct headers for SSE
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Connection'] = 'keep-alive'
    
    # 2. Open the 'Event stream'
    # This block will stay open as long as the user is on the page
    sse = SSE.new(response.stream, event: "metric_update")
    
    begin
      subscriber = ActiveSupport::Notifications.subscribe("metric_saved") do |_name, _start, _finish, _id, payload|
        # Fix: Use Strings "" instead of Symbols :
        sse.write({
          timestamp: payload["created_at"],
          cpu_usage_percent: payload["cpu_usage_percent"],
          memory_usage_percent: payload["memory_usage_percent"],
          network_in_kb: payload["network_in_kb"],
          network_out_kb: payload["network_out_kb"]
        })
      end

      sleep
    rescue IOError, ActionController::Live::ClientDisconnected
      Rails.logger.info "Metrics SSE disconnected"
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
      sse.close
    end
  end

  def simulate_spike
    # 1. Setup the data (Same as before)
    real_metrics = MetricCollectorService.collect
    spike_data = params.permit(:cpu_usage_percent, :memory_usage_percent, :network_in_kb, :network_out_kb)
                      .to_h.compact.transform_values(&:to_f)
    
    final_params = real_metrics.merge(spike_data.stringify_keys)
    duration = (params[:duration_seconds] || 5).to_i # Default to 5 seconds if not sent

    # 2. THE BACKGROUND THREAD
    # We use Thread.new to do the "hard work" while the API replies instantly.
    Thread.new do
      # 1. TURN ON THE LOCK
      Rails.cache.write("simulation_active", true)
      
      begin
        end_time = Time.now + duration
        while Time.now < end_time
          IngestMetricService.new(final_params).execute
          sleep 2 
        end
      ensure
        # 2. TURN OFF THE LOCK (no matter what happens)
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
end