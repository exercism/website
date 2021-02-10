require 'test_helper'

class Notifications::StudentRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track: track
    solution = create :practice_solution, exercise: exercise, user: user
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission
    mentor = create(:user)
    discussion_post = create(:solution_mentor_discussion_post, iteration: iteration, author: mentor)

    notification = Notifications::StudentRepliedToDiscussionNotification.create!(
      user: user,
      params: {
        discussion_post: discussion_post
      }
    )
    assert_equal "#{user.id}-student_replied_to_discussion-DiscussionPost##{discussion_post.id}", notification.uniqueness_key
    assert_equal "#{solution.user.handle} has added a new comment on the solution you are mentoring for #{track.title}:#{exercise.title}", notification.text
    assert_equal "#", notification.url
  end
end
