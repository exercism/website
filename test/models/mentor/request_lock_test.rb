require "test_helper"

class Mentor::RequestLockTest < ActiveSupport::TestCase
  test "expired scope" do
    expired = create :mentor_request_lock, locked_until: Time.current - 1.minute
    current = create :mentor_request_lock, locked_until: Time.current + 1.minute

    assert_equal [expired, current], Mentor::RequestLock.all
    assert_equal [expired], Mentor::RequestLock.expired
  end
end
