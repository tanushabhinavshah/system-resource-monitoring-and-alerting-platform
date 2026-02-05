class IngestMetricService
  def initialize(params)
    @params = params
  end

  def execute
    metric = Metric.new(@params)
    
    if metric.save
      # SHOUT to the stream!
      ActiveSupport::Notifications.instrument("metric_saved", metric.attributes)
      evaluate_all_thresholds(metric) 
      true
    else
      false
    end
  end

  private

  def evaluate_all_thresholds(metric)
    threshold = Threshold.first
    
    # We create a generic method to handle the logic for ANY resource
    evaluate_resource("cpu", metric.cpu_usage_percent, threshold.cpu_threshold, "%")
    evaluate_resource("memory", metric.memory_usage_percent, threshold.memory_threshold, "%")
    evaluate_resource("network_in", metric.network_in_kb, threshold.network_in_threshold, " KB/s")
    evaluate_resource("network_out", metric.network_out_kb, threshold.network_out_threshold, " KB/s")
  end

  def evaluate_resource(resource, current_value, threshold_value, unit)
    # 1. Fetch the MOST RECENT alert event for this specific resource
    latest_alert = Alert.where(resource_type: resource).last

    if current_value > threshold_value
      # If no active alert exists, start a NEW Warning
      if latest_alert.nil? || latest_alert.is_resolved?
        create_alert(resource, "warning", current_value, threshold_value, unit)
      
      # If there is a Warning active, check if it's been more than 1 minute (Escalation)
      elsif latest_alert.severity == "warning" && latest_alert.created_at < 1.minute.ago
        create_alert(resource, "critical", current_value, threshold_value, unit)
      end
      
      # Note: If it's already 'critical', we do nothing. This prevents spamming every 5 seconds!
    else
      # 2. If the metric is back to normal, but an alert is still 'active', we RESOLVE it
      if latest_alert && !latest_alert.is_resolved?
        resolve_alert(resource, current_value, unit)
      end
    end
  end

  def create_alert(resource, severity, value, threshold_value, unit)
    alert = Alert.create!(
      resource_type: resource,
      severity: severity,
      reason: "#{resource.humanize} usage reached #{value}#{unit} (Threshold: #{threshold_value}#{unit})",
      timestamp: Time.current,
      is_resolved: false
    )

    # SHOUT to the stream!
    ActiveSupport::Notifications.instrument("alert_triggered", alert.attributes)

    puts "🚨 [#{severity.upcase}] ALERT: #{resource.humanize} at #{value}#{unit}!"
  end

  def resolve_alert(resource, value, unit)
    alert = Alert.create!(
      resource_type: resource,
      severity: "warning", # We keep the severity context, but mark as resolved
      reason: "#{resource.humanize} recovered to #{value}#{unit}.",
      timestamp: Time.current,
      is_resolved: true
    )

    # SHOUT to the stream!
    ActiveSupport::Notifications.instrument("alert_triggered", alert.attributes)

    puts "✅ RESOLVED: #{resource.humanize} is back to normal."
  end
end