class UpdateDayMetricsJob < ApplicationJob
  queue_as :default

  def perform = MetricPeriod::UpdateDayMetrics.()
end
