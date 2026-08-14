require "test_helper"

class SweepMetricsJobTest < ActiveJob::TestCase
  test "sweeps old metrics" do
    old = create :metric, occurred_at: 8.days.ago
    recent = create :metric, occurred_at: 1.hour.ago

    assert_equal [old, recent], Metric.order(:id).to_a

    SweepMetricsJob.perform_now

    assert_equal [recent], Metric.all.to_a
  end
end
