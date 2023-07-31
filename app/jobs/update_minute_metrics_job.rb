class UpdateMinuteMetricsJob < ApplicationJob
  queue_as :metrics

  def perform = MetricPeriod::UpdateMinuteMetrics.()
end
