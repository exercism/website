require "test_helper"

class MetricPeriod::DayTest < ActiveSupport::TestCase
  test "metric_action uses symbol" do
    metric = create :metric_period_day, metric_action: :complete_solution
    assert_equal :complete_solution, metric.metric_action
  end
end
