require 'test_helper'

class Mentor::Discussion::AwaitingStudentTest < ActiveSupport::TestCase
  test "awaiting student" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current,
        awaiting_student_since: nil,
        status: :awaiting_mentor

      Mentor::Discussion::AwaitingStudent.(discussion)

      assert :awaiting_student, discussion.status
      assert_nil discussion.awaiting_mentor_since
      assert_equal Time.current, discussion.awaiting_student_since
    end
  end

  test "doesn't modernize existing time" do
    freeze_time do
      original = Time.current - 2.weeks

      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current - 1.week,
        awaiting_student_since: original,
        status: :awaiting_mentor

      Mentor::Discussion::AwaitingStudent.(discussion)

      assert_nil discussion.awaiting_mentor_since
      assert_equal original, discussion.awaiting_student_since
    end
  end

  test "doesn't override student_finished" do
    discussion = create :mentor_discussion

    Mentor::Discussion::FinishByStudent.(discussion, 5)
    Mentor::Discussion::AwaitingStudent.(discussion)

    assert :finished, discussion.status
    assert_nil discussion.awaiting_mentor_since
    assert_nil discussion.awaiting_student_since
  end

  test "doesn't override mentor_finished" do
    discussion = create :mentor_discussion
    Mentor::Discussion::FinishByMentor.(discussion)
    Mentor::Discussion::AwaitingStudent.(discussion)

    discussion.reload
    assert :finished, discussion.status
    assert_nil discussion.awaiting_mentor_since
  end
end
