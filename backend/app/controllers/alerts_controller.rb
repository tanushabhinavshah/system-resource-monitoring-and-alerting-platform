class AlertsController < ApplicationController
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Connection'] = 'keep-alive'

    sse = SSE.new(response.stream, event: "alert_event")
    begin
      sse.write({ message: "Alert stream connected" }, event: "ping")
      subscriber = ActiveSupport::Notifications.subscribe("alert_triggered") do |_name, _start, _finish, _id, payload|
        # Fix: Use String keys
        sse.write({
          resource_type: payload["resource_type"],
          severity: payload["severity"],
          is_resolved: payload["is_resolved"],
          reason: payload["reason"],
          event_at: payload["timestamp"] || payload["created_at"]
        })
      end

    
      sleep
    rescue IOError, ActionController::Live::ClientDisconnected
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
      sse.close
    end
  end
end