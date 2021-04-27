require "test_helper"

class ClearMentorRequestLocksJobTest < ActiveJob::TestCase
  test "correct locks are cleared" do
    expired = create :mentor_request_lock, locked_until: Time.current - 1.minute
    current = create :mentor_request_lock, locked_until: Time.current + 1.minute

    assert_equal [expired, current], Mentor::RequestLock.all

    ClearMentorRequestLocksJob.perform_now
    assert_equal [current], Mentor::RequestLock.all
  end
end
