require "test_helper"

class MetricPeriod::MonthTest < ActiveSupport::TestCase
  test "metric_action uses symbol" do
    metric = create :metric_period_month, metric_action: :complete_solution
    assert_equal Metrics::CompleteSolutionMetric, metric.class
  end
end
