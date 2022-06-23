require "test_helper"

class MetricPeriod::MonthTest < ActiveSupport::TestCase
  test "metric_action uses symbol" do
    metric = create :metric_period_month, metric_action: :complete_solution
    assert_equal :complete_solution, metric.metric_action
  end
end
