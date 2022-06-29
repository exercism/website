class UpdateLastHourMetricsJob < ApplicationJob
  queue_as :default

  def perform = MetricPeriod::UpdateLastHourMetrics.()
end
