# This code runs once when the Rails server starts
Rails.application.config.after_initialize do
  # We start the first job. It will then loop every 5 seconds on its own!
  MetricCollectorJob.perform_later
end