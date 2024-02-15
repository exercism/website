require 'test_helper'

class User::Notifications::NudgeMentorToReplyInDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    awaiting_mentor_since = Time.utc(2022, 3, 20)
    student = create :user
    mentor = create :user
    solution = create :concept_solution
    exercise = solution.exercise
    track = solution.track
    discussion = create(:mentor_discussion, mentor:, student:, solution:, awaiting_mentor_since:)

    notification = User::Notifications::NudgeMentorToReplyInDiscussionNotification.create!(
      user: mentor,
      params: {
        discussion:,
        num_days_waiting: 7
      }
    )
    assert_equal "#{mentor.id}|nudge_mentor_to_reply_in_discussion|Discussion##{discussion.id}#2022-03-20#7",
      notification.uniqueness_key
    assert_equal "<strong>#{student.handle}</strong> is waiting for you to reply in the discussion on their solution to <strong>#{exercise.title}</strong> in <strong>#{track.title}</strong>", notification.text # rubocop:disable Layout/LineLength
    assert_equal :avatar, notification.image_type
    assert_equal student.avatar_url, notification.image_url
    assert_equal discussion.mentor_url, notification.url
    assert_equal "/mentoring/discussions/#{discussion.uuid}", notification.path
  end
end
