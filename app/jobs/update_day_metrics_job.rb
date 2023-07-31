class UpdateDayMetricsJob < ApplicationJob
  queue_as :metrics

  def perform = MetricPeriod::UpdateDayMetrics.()
end
