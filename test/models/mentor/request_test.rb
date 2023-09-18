require 'test_helper'

class Mentor::RequestTest < ActiveSupport::TestCase
  test "materialises columns correctly" do
    student = create :user, handle: "someone"
    track = create :track, slug: "foobar"
    exercise = create(:practice_exercise, track:)
    solution = create(:practice_solution, user: student, exercise:)
    req = create(:mentor_request, solution:)
    assert_equal student.id, req.student_id
    assert_equal track.id, req.track_id
    assert_equal exercise.id, req.exercise_id

    assert_equal student, req.student
    assert_equal track, req.track
    assert_equal exercise, req.exercise
  end

  test "locked?" do
    # No lock
    request = create :mentor_request
    refute request.locked?

    # Current Lock
    create :mentor_request_lock, request:, locked_by: create(:user)
    assert request.locked?
  end

  test "lockable_by?" do
    mentor = create :user

    # No lock, fulfilled
    request = create :mentor_request, status: :fulfilled
    refute request.lockable_by?(mentor)

    # Cancelled
    request.update(status: :cancelled)
    refute request.lockable_by?(mentor)

    # Pending
    request.update(status: :pending)
    assert request.lockable_by?(mentor)

    # Locked by mentor
    create :mentor_request_lock, request:, locked_by: mentor
    assert request.lockable_by?(mentor)

    # Active lock by other user
    create :mentor_request_lock, request:, locked_by: create(:user)
    refute request.lockable_by?(mentor)
  end

  test "locked and unlocked scopes" do
    mentor = create :user
    unlocked = create :mentor_request

    locked_by_mentor = create :mentor_request
    create :mentor_request_lock, request: locked_by_mentor, locked_by: mentor

    locked = create :mentor_request
    create :mentor_request_lock, request: locked

    assert_equal [locked_by_mentor, locked], Mentor::Request.locked
    assert_equal [unlocked], Mentor::Request.unlocked
    assert_equal [unlocked, locked_by_mentor], Mentor::Request.unlocked_for(mentor)
  end

  test "validates comment_markdown correctly" do
    refute build(:mentor_request, comment_markdown: "").valid?

    request = create :mentor_request
    assert_raises do
      request.update!(comment_markdown: "")
    end

    request = create :mentor_request
    request.update_columns(comment_markdown: '') # Skip validations
    assert_equal "", request.reload.comment_markdown
    request.fulfilled! # Check this still works
  end
end
