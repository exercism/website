class UpdateMonthMetricsJob < ApplicationJob
  queue_as :metrics

  def perform = MetricPeriod::UpdateMonthMetrics.()
end
