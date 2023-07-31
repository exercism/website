class UpdateLastWeekMetricsJob < ApplicationJob
  queue_as :metrics

  def perform = MetricPeriod::UpdateLastWeekMetrics.()
end
