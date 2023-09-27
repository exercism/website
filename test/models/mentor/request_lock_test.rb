require "test_helper"

class Mentor::RequestLockTest < ActiveSupport::TestCase
  test "expired scope" do
    expired = create :mentor_request_lock, locked_until: Time.current - 1.minute
    current = create :mentor_request_lock, locked_until: Time.current + 1.minute

    assert_equal [expired, current], Mentor::RequestLock.all
    assert_equal [expired], Mentor::RequestLock.expired
  end

  test "lock is considered expired" do
    lock = create :mentor_request_lock, locked_until: Time.current - 1.minute
    assert lock.expired?
  end

  test "lock is not considered expired" do
    lock = create :mentor_request_lock, locked_until: Time.current + 1.minute
    refute lock.expired?
  end

  test "extend an unexpired lock" do
    lock = create :mentor_request_lock, locked_until: Time.current + 10.minutes
    lock.extend!
    assert_equal (Time.current + 30.minutes).to_i, lock.locked_until.to_i
  end

  test "raise error when extending an expired lock" do
    lock = create :mentor_request_lock, locked_until: Time.current - 1.second
    assert_raises(RequestLockHasExpired) { lock.extend! }
  end
end
