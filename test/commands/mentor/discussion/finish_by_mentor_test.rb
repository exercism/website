require 'test_helper'

class Mentor::Discussion::FinishByMentorTest < ActiveSupport::TestCase
  test "finishes" do
    freeze_time do
      discussion = create :mentor_discussion

      Mentor::Discussion::FinishByMentor.(discussion)

      assert_equal :mentor_finished, discussion.status
    end
  end

  test "sends notification to student" do
    mentor = create :user, handle: "mentor"
    student = create :user, email: "student@exercism.org"
    track = create :track, title: "Ruby"
    exercise = create :concept_exercise, title: "Strings", track: track
    solution = create :concept_solution, user: student, exercise: exercise
    discussion = create :mentor_discussion, mentor: mentor, solution: solution

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
