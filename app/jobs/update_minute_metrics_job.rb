class UpdateMinuteMetricsJob < ApplicationJob
  queue_as :default

  def perform = MetricPeriod::UpdateMinuteMetrics.()
end
