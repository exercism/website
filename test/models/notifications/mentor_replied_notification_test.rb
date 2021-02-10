require 'test_helper'

class Notifications::MentorRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track: track
    solution = create :practice_solution, exercise: exercise, user: user
    iteration = create :iteration, solution: solution
    mentor = create(:user)
    discussion_post = create(:solution_mentor_discussion_post, iteration: iteration, author: mentor)

    notification = Notifications::MentorRepliedToDiscussionNotification.create!(
      user: user,
      params: { discussion_post: discussion_post }
    )
    assert_equal "#", notification.url
    assert_equal "#{user.id}-mentor_replied_to_discussion-DiscussionPost##{discussion_post.id}", notification.uniqueness_key
    assert_equal "#{mentor.handle} has added a new comment on your solution to #{track.title}:#{exercise.title}", notification.text
    assert_equal :avatar, notification.image_type
    assert_equal mentor.avatar_url, notification.image_url
  end
end
