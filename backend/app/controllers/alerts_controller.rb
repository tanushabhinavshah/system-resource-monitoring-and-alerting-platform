class AlertsController < ApplicationController
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    
    # We use 'alert_event' to match your OpenAPI spec 'event: alert_event'
    sse = SSE.new(response.stream, event: "alert_event")
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

    begin
      loop { sleep 1 }
    rescue IOError, ActionController::Live::ClientDisconnected
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
      sse.close
    end
  end
end