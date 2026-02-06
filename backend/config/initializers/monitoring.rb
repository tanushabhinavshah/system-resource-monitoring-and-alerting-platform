# This code runs once when the Rails server starts
Rails.application.config.after_initialize do
  # We start the first job. It will then loop every 5 seconds on its own!
  if defined?(Rails::Server) || File.basename($0) == 'rails' && ARGV.include?('server')
    MetricCollectorJob.perform_later
  end
end