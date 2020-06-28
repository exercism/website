require 'test_helper'

class Notifications::MentorRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "anti_duplicate_key" do
    user = create :user
    discussion_post = create(:iteration_discussion_post)

    notification = Notifications::MentorRepliedToDiscussionNotification.create!(
      user: user,
      params: { discussion_post: discussion_post }
    )
    key = "#{user.id}-mentor_replied_to_discussion-DiscussionPost##{discussion_post.id}"
    assert_equal key, notification.anti_duplicate_key
  end

  test "text is valid" do
    track = create :track
    exercise = create :practice_exercise, track: track
    solution = create :practice_solution, exercise: exercise
    iteration = create :iteration, solution: solution
    mentor = create(:user)
    discussion_post = create(:iteration_discussion_post, iteration: iteration, user: mentor)

    notification = Notifications::MentorRepliedToDiscussionNotification.create!(
      user: create(:user),
      params: { discussion_post: discussion_post }
    )
    assert_equal "#{mentor.handle} has added a new comment on your solution to #{track.title}:#{exercise.title}", notification.text
  end
end
