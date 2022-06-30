require "test_helper"

class MetricPeriod::MinuteTest < ActiveSupport::TestCase
  test "metric_action uses symbol" do
    metric = create :metric_period_minute, metric_action: :complete_solution
    assert_equal Metrics::CompleteSolutionMetric, metric.class
  end
end
