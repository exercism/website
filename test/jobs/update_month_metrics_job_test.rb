require "test_helper"

class UpdateMonthMetricsJobTest < ActiveJob::TestCase
  test "month metrics are updated" do
    MetricPeriod::UpdateMonthMetrics.expects(:call).with

    UpdateMonthMetricsJob.perform_now
  end
end
