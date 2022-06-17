class UpdateHourMetricsJob < ApplicationJob
  queue_as :default

  def perform = MetricPeriod::UpdateHourMetrics.()
end
