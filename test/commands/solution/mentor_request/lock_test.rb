require "test_helper"

class Solution::MentorRequest::LockTest < ActiveSupport::TestCase
  test "locks request" do
    freeze_time do
      mentor = create :user
      request = create :solution_mentor_request

      Solution::MentorRequest::Lock.(request, mentor)

      assert request.reload.locked?
      assert_equal Time.current + 30.minutes, request.locked_until
      assert_equal mentor, request.locked_by
    end
  end

  test "extends if already locked by the mentor" do
    freeze_time do
      mentor = create :user
      request = create :solution_mentor_request, locked_until: Time.current + 5.minutes, locked_by: mentor

      Solution::MentorRequest::Lock.(request, mentor)

      assert request.reload.locked?
      assert_equal Time.current + 30.minutes, request.locked_until
      assert_equal mentor, request.locked_by
    end
  end

  test "locks if previous lock has expired" do
    freeze_time do
      mentor = create :user
      request = create :solution_mentor_request, locked_until: Time.current - 5.minutes, locked_by: create(:user)

      Solution::MentorRequest::Lock.(request, mentor)

      assert request.reload.locked?
      assert_equal Time.current + 30.minutes, request.locked_until
      assert_equal mentor, request.locked_by
    end
  end

  test "raises if solution is by someone else locked" do
    mentor = create :user
    request = create :solution_mentor_request, locked_until: Time.current + 5.minutes, locked_by: create(:user)

    assert_raises SolutionLockedByAnotherMentorError do
      Solution::MentorRequest::Lock.(request, mentor)
    end
  end
end
