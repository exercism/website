require "test_helper"

class DeleteOldMetricsTest < ActiveSupport::TestCase
  test "updates num_users" do
    create :metric, occurred_at: Time.current - 3.months - 2.days
    old = create :metric, occurred_at: Time.current - 3.months + 2.days
    new = create :metric, occurred_at: Time.current

    DeleteOldMetrics.perform_now
    assert_equal [old, new], Metric.all
  end
end
