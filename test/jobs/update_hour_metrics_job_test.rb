require "test_helper"

class UpdateHourMetricsJobTest < ActiveJob::TestCase
  test "hour metrics are updated" do
    MetricPeriod::UpdateHourMetrics.expects(:call).with

    UpdateHourMetricsJob.perform_now
  end
end
