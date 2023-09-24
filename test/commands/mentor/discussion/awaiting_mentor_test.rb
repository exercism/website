require 'test_helper'

class Mentor::Discussion::AwaitingMentorTest < ActiveSupport::TestCase
  test "awaiting mentor" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_student_since: Time.current,
        awaiting_mentor_since: nil,
        status: :awaiting_student

      Mentor::Discussion::AwaitingMentor.(discussion)

      assert :awaiting_mentor, discussion.status
      assert_nil discussion.awaiting_student_since
      assert_equal Time.current, discussion.awaiting_mentor_since
    end
  end

  test "doesn't modernize existing time" do
    freeze_time do
      original = Time.current - 2.weeks

      discussion = create :mentor_discussion,
        awaiting_student_since: Time.current - 1.week,
        awaiting_mentor_since: original,
        status: :awaiting_student

      Mentor::Discussion::AwaitingMentor.(discussion)

      assert_nil discussion.awaiting_student_since
      assert_equal original, discussion.awaiting_mentor_since
    end
  end

  test "doesn't override student_finished" do
    discussion = create :mentor_discussion
    Mentor::Discussion::FinishByStudent.(discussion, 5)
    Mentor::Discussion::AwaitingMentor.(discussion)

    assert :finished, discussion.status
    assert_nil discussion.awaiting_mentor_since
    assert_nil discussion.awaiting_student_since
  end

  test "doesn't override mentor_finished" do
    discussion = create :mentor_discussion
    Mentor::Discussion::FinishByMentor.(discussion)
    Mentor::Discussion::AwaitingMentor.(discussion)

    assert :finished, discussion.status
    assert_nil discussion.awaiting_mentor_since
  end
end
