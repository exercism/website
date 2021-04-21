require 'test_helper'

class Mentor::RequestTest < ActiveSupport::TestCase
  test "locked?" do
    # No lock
    request = create :mentor_request, locked_until: nil
    refute request.locked?

    # Expired Lock
    request.update(locked_by: create(:user), locked_until: Time.current - 5.minutes)
    refute request.locked?

    # Current Lock
    request.update(locked_by: create(:user), locked_until: Time.current + 5.minutes)
    assert request.locked?
  end

  test "lockable_by?" do
    mentor = create :user

    # No lock, fulfilled
    request = create :mentor_request, locked_until: nil, status: :fulfilled
    refute request.lockable_by?(mentor)

    # Cancelled
    request.update(status: :cancelled)
    refute request.lockable_by?(mentor)

    # Pending
    request.update(status: :pending)
    assert request.lockable_by?(mentor)

    # Locked by mentor
    request.update(locked_by: mentor, locked_until: Time.current + 5.minutes)
    assert request.lockable_by?(mentor)

    # Expired locked by mentor
    request.update(locked_by: mentor, locked_until: Time.current - 5.minutes)
    assert request.lockable_by?(mentor)

    # Expired lock by other user
    request.update(locked_by: create(:user), locked_until: Time.current - 5.minutes)
    assert request.lockable_by?(mentor)

    # Active lock by other user
    request.update(locked_by: create(:user), locked_until: Time.current + 5.minutes)
    refute request.lockable_by?(mentor)
  end

  test "locked and unlocked scopes" do
    mentor = create :user
    unlocked = create :mentor_request, locked_until: nil
    locked_by_mentor = create :mentor_request, locked_until: Time.current + 5.minutes, locked_by: mentor
    locked = create :mentor_request, locked_until: Time.current + 5.minutes
    expired = create :mentor_request, locked_until: Time.current - 5.minutes

    assert_equal [locked_by_mentor, locked], Mentor::Request.locked
    assert_equal [unlocked, expired], Mentor::Request.unlocked
    assert_equal [unlocked, locked_by_mentor, expired], Mentor::Request.unlocked_for(mentor)
  end
end
