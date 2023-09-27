require "test_helper"

class Mentor::Request::LockTest < ActiveSupport::TestCase
  test "locks request" do
    freeze_time do
      mentor = create :user
      request = create :mentor_request

      Mentor::Request::Lock.(request, mentor)

      assert request.reload.locked?
      lock = request.locks.last
      assert_equal Time.current + 30.minutes, lock.locked_until
      assert_equal mentor, lock.locked_by
    end
  end

  test "extends if already locked by the mentor" do
    freeze_time do
      mentor = create :user
      request = create :mentor_request
      create :mentor_request_lock, request:, locked_by: mentor, locked_until: Time.current + 5.minutes

      Mentor::Request::Lock.(request, mentor)

      assert request.reload.locked?
      lock = request.locks.last
      assert_equal Time.current + 30.minutes, lock.locked_until
      assert_equal mentor, lock.locked_by
    end
  end

  test "locks if previous lock has expired" do
    freeze_time do
      mentor = create :user
      request = create :mentor_request
      create :mentor_request_lock, request:, locked_by: mentor, locked_until: Time.current - 5.minutes

      Mentor::Request::Lock.(request, mentor)

      assert request.reload.locked?
      lock = request.locks.last
      assert_equal Time.current + 30.minutes, lock.locked_until
      assert_equal mentor, lock.locked_by
    end
  end

  test "raises if solution is by someone else locked" do
    mentor = create :user
    request = create :mentor_request
    create :mentor_request_lock, request:, locked_until: Time.current + 5.minutes

    assert_raises SolutionLockedByAnotherMentorError do
      Mentor::Request::Lock.(request, mentor)
    end
  end

  test "raises if mentor has four open locks" do
    mentor = create :user

    # Sanity check: can lock when mentor has no existing locks
    Mentor::Request::Lock.(create(:mentor_request), mentor)

    # Sanity check: can lock when mentor has less than four existing locks
    3.times { Mentor::Request::Lock.(create(:mentor_request), mentor.reload) }

    assert_raises MentorSolutionLockLimitReachedError do
      Mentor::Request::Lock.(create(:mentor_request), mentor.reload)
    end
  end
end
