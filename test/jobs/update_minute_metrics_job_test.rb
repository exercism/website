require "test_helper"

class UpdateMinuteMetricsJobTest < ActiveJob::TestCase
  test "minute metrics are updated" do
    MetricPeriod::UpdateMinuteMetrics.expects(:call).with

    UpdateMinuteMetricsJob.perform_now
  end
end
