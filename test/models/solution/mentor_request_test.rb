require 'test_helper'

class Solution::MentorRequestTest < ActiveSupport::TestCase
  test "locked?" do
    # No lock
    request = create :solution_mentor_request, locked_until: nil
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

    # No lock
    request = create :solution_mentor_request, locked_until: nil
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
end
