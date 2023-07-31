require 'test_helper'

class User::Notifications::MentorRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:)
    solution = create(:practice_solution, exercise:, user:)
    iteration = create(:iteration, solution:)
    mentor = create(:user)
    discussion_post = create(:mentor_discussion_post, iteration:, author: mentor)

    notification = User::Notifications::MentorRepliedToDiscussionNotification.create!(
      user:,
      params: { discussion_post: }
    )
    assert_equal "#{user.id}|mentor_replied_to_discussion|DiscussionPost##{discussion_post.id}", notification.uniqueness_key
    assert_equal "<strong>#{mentor.handle}</strong> has added a new comment on your solution to <strong>#{exercise.title}</strong> in <strong>#{track.title}</strong>", # rubocop:disable Layout/LineLength
      notification.text
    assert_equal :avatar, notification.image_type
    assert_equal mentor.avatar_url, notification.image_url
    assert_equal discussion_post.discussion.student_url, notification.url
    assert_equal "/tracks/#{track.slug}/exercises/#{exercise.slug}/mentor_discussions/#{discussion_post.discussion.uuid}",
      notification.path
  end
end
