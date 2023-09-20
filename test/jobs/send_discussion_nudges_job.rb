require "test_helper"

class SendMentorDiscussionNudgesJobTest < ActiveJob::TestCase
  test "sends nudges" do
    Mentor::Discussion::SendNudges.expects(:call)

    SendMentorDiscussionNudgesJob.perform_now
  end
end
