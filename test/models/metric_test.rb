require "test_helper"

class MetricTest < ActiveSupport::TestCase
  test "action uses symbol" do
    metric = create :metric, action: :complete_solution
    assert_equal :complete_solution, metric.metric_action
  end
end
