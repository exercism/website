class SweepMetricsJob < ApplicationJob
  queue_as :metrics

  def perform = Metric::Sweep.()
end
