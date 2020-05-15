require "test_helper"

class Mentor::LockRequestTest < ActiveSupport::TestCase
  test "locks request" do
    Timecop.freeze do
      mentor = create :user
      request = create :solution_mentor_request

      Mentor::LockRequest.(mentor, request)

      assert request.reload.locked?
      assert_equal Time.current + 30.minutes, request.locked_until
      assert_equal mentor, request.locked_by
    end
  end

  test "extends if already locked by the mentor" do
    Timecop.freeze do
      mentor = create :user
      request = create :solution_mentor_request, locked_until: Time.current + 5.minutes, locked_by: mentor

      Mentor::LockRequest.(mentor, request)

      assert request.reload.locked?
      assert_equal Time.current + 30.minutes, request.locked_until
      assert_equal mentor, request.locked_by
    end
  end

  test "locks if previous lock has expired" do
    Timecop.freeze do
      mentor = create :user
      request = create :solution_mentor_request, locked_until: Time.current - 5.minutes, locked_by: create(:user)

      Mentor::LockRequest.(mentor, request)

      assert request.reload.locked?
      assert_equal Time.current + 30.minutes, request.locked_until
      assert_equal mentor, request.locked_by
    end
  end

  test "raises if solution is by someone else locked" do
    mentor = create :user
    request = create :solution_mentor_request, locked_until: Time.current + 5.minutes, locked_by: create(:user)

    assert_raises SolutionLockedByAnotherMentorError do
      Mentor::LockRequest.(mentor, request)
    end
  end
end


