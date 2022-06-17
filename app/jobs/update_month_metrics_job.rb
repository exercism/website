class UpdateMonthMetricsJob < ApplicationJob
  queue_as :default

  def perform = MetricPeriod::UpdateMonthMetrics.()
end
