require 'test_helper'

class User::Notifications::MentorTimedOutDiscussionMentorNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    student = create :user
    mentor = create :user
    solution = create :concept_solution, user: student
    exercise = solution.exercise
    track = solution.track
    discussion = create(:mentor_discussion, mentor:, student:, solution:)

    notification = User::Notifications::MentorTimedOutDiscussionMentorNotification.create!(
      user: mentor,
      params: {
        discussion:
      }
    )
    assert_equal "#{mentor.id}|mentor_timed_out_discussion_mentor|Discussion##{discussion.id}",
      notification.uniqueness_key
    assert_equal "Your mentoring session on the solution by <strong>#{student.handle}</strong> to <strong>#{exercise.title}</strong> in <strong>#{track.title}</strong> has timed out", notification.text # rubocop:disable Layout/LineLength
    assert_equal :avatar, notification.image_type
    assert_equal student.avatar_url, notification.image_url
    assert_equal discussion.mentor_url, notification.url
    assert_equal "/mentoring/discussions/#{discussion.uuid}", notification.path
  end
end
