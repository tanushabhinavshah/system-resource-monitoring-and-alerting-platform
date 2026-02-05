class MetricCollectorJob < ApplicationJob
  queue_as :default

  def perform
    # 1. Run our MetricCollectorService 
    MetricCollectorService.collect

    # 2. Tell Rails to run this same job again in 5 seconds
    # This is the "Heartbeat" loop
    MetricCollectorJob.set(wait: 3.seconds).perform_later
  end
end