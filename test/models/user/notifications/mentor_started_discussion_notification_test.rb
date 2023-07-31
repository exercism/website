require 'test_helper'

class User::Notifications::MentorStartedDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user
    mentor = create :user
    solution = create :concept_solution
    exercise = solution.exercise
    track = solution.track
    discussion = create(:mentor_discussion, mentor:, solution:)
    discussion_post = create(:mentor_discussion_post)

    notification = User::Notifications::MentorStartedDiscussionNotification.create!(
      user:,
      params: {
        discussion:,
        discussion_post:
      }
    )
    assert_equal "#{user.id}|mentor_started_discussion|Discussion##{discussion.id}", notification.uniqueness_key
    assert_equal "<strong>#{mentor.handle}</strong> has started mentoring your solution to <strong>#{exercise.title}</strong> in <strong>#{track.title}</strong>", notification.text # rubocop:disable Layout/LineLength
    assert_equal :avatar, notification.image_type
    assert_equal mentor.avatar_url, notification.image_url
    assert_equal discussion.student_url, notification.url
    assert_equal "/tracks/#{track.slug}/exercises/#{exercise.slug}/mentor_discussions/#{discussion.uuid}", notification.path
  end
end
