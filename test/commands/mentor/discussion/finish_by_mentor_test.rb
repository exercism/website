require 'test_helper'

class Mentor::Discussion::FinishByMentorTest < ActiveSupport::TestCase
  test "finishes" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current,
        awaiting_student_since: nil,
        status: :awaiting_mentor

      Mentor::Discussion::FinishByMentor.(discussion)

      assert :mentor_finished, discussion.status
      assert_nil discussion.awaiting_mentor_since
      assert_equal Time.current, discussion.finished_at
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

      Mentor::Discussion::FinishByMentor.(discussion)

      assert_nil discussion.awaiting_mentor_since
      assert_equal original, discussion.awaiting_student_since
    end
  end

  test "sends notification to student" do
    mentor = create :user, handle: "mentor"
    student = create :user, email: "student@exercism.org"
    track = create :track, title: "Ruby"
    exercise = create(:concept_exercise, title: "Strings", track:)
    solution = create(:concept_solution, user: student, exercise:)
    discussion = create(:mentor_discussion, mentor:, solution:)

    perform_enqueued_jobs do
      Mentor::Discussion::FinishByMentor.(discussion)
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal(
      "[Mentoring] mentor has ended your discussion on Ruby/Strings",
      email.subject
    )
    assert_equal [student.email], email.to

    ActionMailer::Base.deliveries.clear
  end
end
