require 'test_helper'

class User::Notifications::MentorTimedOutDiscussionStudentNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    student = create :user
    mentor = create :user
    solution = create :concept_solution, user: student
    exercise = solution.exercise
    track = solution.track
    discussion = create(:mentor_discussion, mentor:, student:, solution:)

    notification = User::Notifications::MentorTimedOutDiscussionStudentNotification.create!(
      user: student,
      params: {
        discussion:
      }
    )
    assert_equal "#{student.id}|mentor_timed_out_discussion_student|Discussion##{discussion.id}",
      notification.uniqueness_key
    assert_equal "The discussion on your solution to <strong>#{exercise.title}</strong> in <strong>#{track.title}</strong> has timed out", notification.text # rubocop:disable Layout/LineLength
    assert_equal :avatar, notification.image_type
    assert_equal mentor.avatar_url, notification.image_url
    assert_equal discussion.student_url, notification.url
    assert_equal "/tracks/#{track.slug}/exercises/#{exercise.slug}/mentor_discussions/#{discussion.uuid}", notification.path
  end
end
