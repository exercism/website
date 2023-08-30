require "test_helper"

class SendDiscussionNudgesJobTest < ActiveJob::TestCase
  test "sends nudges" do
    Mentor::Discussion::SendNudges.expects(:call)

    SendDiscussionNudgesJob.perform_now
  end
end
