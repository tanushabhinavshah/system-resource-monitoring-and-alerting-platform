class MetricsController < ApplicationController
  include ActionController::Live

  def stream
    # 1. Set the correct headers for SSE
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate
    
    # 2. Open the 'Event stream'
    # This block will stay open as long as the user is on the page
    sse = SSE.new(response.stream, event: "metric_update")

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

    begin
      # Keep the connection alive (loop forever until user leaves)
      loop { sleep 1 }
    rescue IOError, ActionController::Live::ClientDisconnected
      # Clean up if the user closes the tab
    ensure
      # Fix: Stop listening when the user leaves!
      ActiveSupport::Notifications.unsubscribe(subscriber)
      sse.close
    end
  end
end