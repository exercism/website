require 'test_helper'

class Mentor::Discussion::StudentTimedOutTest < ActiveSupport::TestCase
  test "finishes" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_student_since: Time.current,
        awaiting_mentor_since: nil,
        status: :awaiting_mentor

      Mentor::Discussion::StudentTimedOut.(discussion)

      assert :mentor_timed_out, discussion.status
      assert_nil discussion.awaiting_student_since
      assert_nil discussion.awaiting_mentor_since
      assert_equal Time.current, discussion.finished_at
      assert_equal :student_timed_out, discussion.finished_by
    end
  end

  test "sends notification to student" do
    mentor = create :user, email: "mentor@exercism.org"
    student = create :user, email: "student@exercism.org"
    track = create :track, title: "Ruby"
    exercise = create(:concept_exercise, title: "Strings", track:)
    solution = create(:concept_solution, user: student, exercise:)
    discussion = create(:mentor_discussion, mentor:, solution:)

    perform_enqueued_jobs do
      Mentor::Discussion::StudentTimedOut.(discussion)
    end

    email = ActionMailer::Base.deliveries.find { |mail| mail.to == [student.email] }
    assert_equal "Your mentoring discussion on Ruby/Strings has timed out", email.subject

    ActionMailer::Base.deliveries.clear
  end

  test "sends notification to mentor" do
    mentor = create :user, email: "mentor@exercism.org"
    student = create :user, email: "student@exercism.org"
    track = create :track, title: "Ruby"
    exercise = create(:concept_exercise, title: "Strings", track:)
    solution = create(:concept_solution, user: student, exercise:)
    discussion = create(:mentor_discussion, mentor:, solution:)

    perform_enqueued_jobs do
      Mentor::Discussion::StudentTimedOut.(discussion)
    end

    email = ActionMailer::Base.deliveries.find { |mail| mail.to == [mentor.email] }
    assert_equal "[Mentoring] Your mentoring session has timed out due to lack of student response.", email.subject

    ActionMailer::Base.deliveries.clear
  end
end
