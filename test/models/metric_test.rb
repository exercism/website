require "test_helper"

class MetricTest < ActiveSupport::TestCase
  test "metric_action uses symbol" do
    metric = create :metric, metric_action: :complete_solution
    assert_equal :complete_solution, metric.metric_action
  end
end
