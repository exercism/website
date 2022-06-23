require "test_helper"

class MetricPeriod::MinuteTest < ActiveSupport::TestCase
  test "metric_action uses symbol" do
    metric = create :metric_period_minute, metric_action: :complete_solution
    assert_equal :complete_solution, metric.metric_action
  end
end
