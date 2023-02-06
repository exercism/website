class UpdateMetricStatsJob < ApplicationJob
  queue_as :metrics

  def perform = Metrics::UpdateStats.()
end
