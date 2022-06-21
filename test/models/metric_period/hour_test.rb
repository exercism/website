require "test_helper"

class MetricPeriod::HourTest < ActiveSupport::TestCase
  test "action uses symbol" do
    metric = create :metric_period_hour, action: :complete_solution
    assert_equal :complete_solution, metric.metric_action
  end
end
