class UpdateLastHourMetricsJob < ApplicationJob
  queue_as :metrics

  def perform = MetricPeriod::UpdateLastHourMetrics.()
end
