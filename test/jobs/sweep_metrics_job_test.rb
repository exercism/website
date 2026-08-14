require "test_helper"

class SweepMetricsJobTest < ActiveJob::TestCase
  test "sweeps metrics" do
    Metric::Sweep.expects(:call)

    SweepMetricsJob.perform_now
  end
end
