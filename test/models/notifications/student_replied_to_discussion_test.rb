require 'test_helper'

class Notifications::StudentRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "uniqueness_key" do
    user = create :user
    discussion_post = create(:solution_mentor_discussion_post)

    notification = Notifications::StudentRepliedToDiscussionNotification.create!(
      user: user,
      params: {
        discussion_post: discussion_post
      }
    )
    key = "#{user.id}-student_replied_to_discussion-DiscussionPost##{discussion_post.id}"
    assert_equal key, notification.uniqueness_key
  end

  test "text is valid" do
    track = create :track
    exercise = create :practice_exercise, track: track
    solution = create :practice_solution, exercise: exercise
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission
    mentor = create(:user)
    discussion_post = create(:solution_mentor_discussion_post, iteration: iteration, author: mentor)

    notification = Notifications::StudentRepliedToDiscussionNotification.create!(
      user: mentor,
      params: {
        discussion_post: discussion_post
      }
    )
    assert_equal "#{solution.user.handle} has added a new comment on the solution you are mentoring for #{track.title}:#{exercise.title}", notification.text
  end
end
