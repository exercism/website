require "test_helper"

class Metric::SweepTest < ActiveSupport::TestCase
  test "deletes metrics older than the retention period" do
    old = create :metric, occurred_at: 8.days.ago
    boundary = create :metric, occurred_at: 7.days.ago + 1.minute
    recent = create :metric, occurred_at: 1.hour.ago

    Metric::Sweep.()

    assert_equal [boundary, recent], Metric.order(:id).to_a
    refute Metric.exists?(old.id)
  end

  test "deletes many rows" do
    3.times { |i| create :metric, occurred_at: (30 + i).days.ago }

    Metric::Sweep.()

    assert_equal 0, Metric.count
  end

  test "does nothing when there is nothing to sweep" do
    metric = create :metric, occurred_at: Time.current

    Metric::Sweep.()

    assert_equal [metric], Metric.all.to_a
  end
end
