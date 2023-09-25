require 'test_helper'

class Mentor::Discussion::MentorTimedOutTest < ActiveSupport::TestCase
  test "finishes" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current,
        awaiting_student_since: nil,
        status: :awaiting_mentor

      Mentor::Discussion::MentorTimedOut.(discussion)

      assert :mentor_timed_out, discussion.status
      assert_nil discussion.awaiting_mentor_since
      assert_nil discussion.awaiting_student_since
      assert_equal Time.current, discussion.finished_at
      assert_equal :mentor_timed_out, discussion.finished_by
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
      Mentor::Discussion::MentorTimedOut.(discussion)
    end

    email = ActionMailer::Base.deliveries.find { |mail| mail.to == [student.email] }
    assert_equal "The discussion on your solution to Ruby/Strings has timed out", email.subject

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
      Mentor::Discussion::MentorTimedOut.(discussion)
    end

    email = ActionMailer::Base.deliveries.find { |mail| mail.to == [mentor.email] }
    assert_equal "[Mentoring] Your mentoring session has timed out due to lack of response by you.", email.subject

    ActionMailer::Base.deliveries.clear
  end
end
