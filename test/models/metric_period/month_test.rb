require "test_helper"

class MetricPeriod::MonthTest < ActiveSupport::TestCase
  test "action uses symbol" do
    metric = create :metric_period_month, action: :complete_solution
    assert_equal :complete_solution, metric.action
  end
end
