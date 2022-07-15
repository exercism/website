class UpdateLastQuarterMetricsJob < ApplicationJob
  queue_as :metrics

  def perform = MetricPeriod::UpdateLastQuarterMetrics.()
end
