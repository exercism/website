require 'test_helper'

class User::Notifications::NudgeStudentToReplyInDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    awaiting_student_since = Time.utc(2022, 3, 20)
    user = create :user
    mentor = create :user
    solution = create :concept_solution
    exercise = solution.exercise
    track = solution.track
    discussion = create(:mentor_discussion, mentor:, solution:, awaiting_student_since:)

    notification = User::Notifications::NudgeStudentToReplyInDiscussionNotification.create!(
      user:,
      params: {
        discussion:,
        num_days_waiting: 7
      }
    )
    assert_equal "#{user.id}|nudge_student_to_reply_in_discussion|Discussion##{discussion.id}#2022-03-20#7",
      notification.uniqueness_key
    assert_equal "<strong>#{mentor.handle}</strong> is waiting for you to reply in the discussion on your solution to <strong>#{exercise.title}</strong> in <strong>#{track.title}</strong>", notification.text # rubocop:disable Layout/LineLength
    assert_equal :avatar, notification.image_type
    assert_equal mentor.avatar_url, notification.image_url
    assert_equal discussion.student_url, notification.url
    assert_equal "/tracks/#{track.slug}/exercises/#{exercise.slug}/mentor_discussions/#{discussion.uuid}", notification.path
  end
end
