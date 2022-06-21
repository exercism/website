require "test_helper"

class MetricPeriod::UpdateHourMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "metrics are counted per hour" do
    freeze_time do
      create :metric, created_at: Time.now.utc.change(hour: 0)
      create :metric, created_at: Time.now.utc.change(hour: 0)
      create :metric, created_at: Time.now.utc.change(hour: 15)
      create :metric, created_at: Time.now.utc.change(hour: 15)
      create :metric, created_at: Time.now.utc.change(hour: 15)
      create :metric, created_at: Time.now.utc.change(hour: 23)
    end

    MetricPeriod::UpdateHourMetrics.()

    assert_equal 2, MetricPeriod::Hour.find_by(hour: 0).count
    assert_equal 3, MetricPeriod::Hour.find_by(hour: 15).count
    assert_equal 1, MetricPeriod::Hour.find_by(hour: 23).count
  end
end
