require 'test_helper'

class User::Notifications::StudentAddedIteration < ActiveSupport::TestCase
  test "keys are valid" do
    student = create :user, handle: "student"
    mentor = create :user
    track = create :track, title: "Ruby"
    exercise = create :concept_exercise, title: "Strings", track: track
    solution = create :concept_solution, user: student, exercise: exercise
    discussion = create :mentor_discussion, solution: solution, mentor: mentor
    submission = create :submission, solution: solution
    iteration = create :iteration, solution: solution, submission: submission, idx: 2

    notification = User::Notifications::StudentAddedIterationNotification.create!(
      user: mentor,
      params: {
        discussion:,
        iteration:
      }
    )
    assert_equal "#{mentor.id}|student_added_iteration|Discussion##{discussion.id}|Iteration##{iteration.id}",
      notification.uniqueness_key
    assert_equal "Your student, student, has submitted a new iteration (#2) on their solution to Ruby: Strings", notification.text  # rubocop:disable Layout/LineLength

    assert_equal :avatar, notification.image_type
    assert_equal student.avatar_url, notification.image_url
    assert_equal discussion.mentor_url, notification.url
    assert_equal "/mentoring/discussions/#{discussion.uuid}", notification.path
  end
end
