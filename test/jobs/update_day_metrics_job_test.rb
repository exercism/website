require "test_helper"

class UpdateDayMetricsJobTest < ActiveJob::TestCase
  test "day metrics are updated" do
    MetricPeriod::UpdateDayMetrics.expects(:call).with

    UpdateDayMetricsJob.perform_now
  end
end
