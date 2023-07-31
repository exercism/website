require "test_helper"

class UpdateMedianWaitTimesJobTest < ActiveJob::TestCase
  test "track median wait times are updated" do
    Track::UpdateMedianWaitTimes.expects(:call)
    UpdateMedianWaitTimesJob.perform_now
  end

  test "exercise median wait times are updated" do
    Exercise::UpdateMedianWaitTimes.expects(:call)
    UpdateMedianWaitTimesJob.perform_now
  end
end
