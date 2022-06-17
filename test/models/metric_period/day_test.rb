require "test_helper"

class MetricPeriod::DayTest < ActiveSupport::TestCase
  test "action uses symbol" do
    metric = create :metric_period_day, action: :complete_solution
    assert_equal :complete_solution, metric.action
  end
end
