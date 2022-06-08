require 'test_helper'

class User::Notifications::MentorRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track: track
    solution = create :practice_solution, exercise: exercise, user: user
    iteration = create :iteration, solution: solution
    mentor = create(:user)
    discussion_post = create(:mentor_discussion_post, iteration:, author: mentor)

    notification = User::Notifications::MentorRepliedToDiscussionNotification.create!(
      user:,
      params: { discussion_post: }
    )
    assert_equal "#{user.id}|mentor_replied_to_discussion|DiscussionPost##{discussion_post.id}", notification.uniqueness_key
    assert_equal "#{mentor.handle} has added a new comment on your solution to #{track.title}: #{exercise.title}",
      notification.text
    assert_equal :avatar, notification.image_type
    assert_equal mentor.avatar_url, notification.image_url
    assert_equal discussion_post.discussion.student_url, notification.url
    assert_equal "/tracks/#{track.slug}/exercises/#{exercise.slug}/mentor_discussions/#{discussion_post.discussion.uuid}",
      notification.path
  end
end
