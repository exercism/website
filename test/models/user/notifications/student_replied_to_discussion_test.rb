require 'test_helper'

class User::Notifications::StudentRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track: track
    solution = create :practice_solution, exercise: exercise, user: user
    student = solution.user
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission
    mentor = create(:user)
    discussion_post = create(:solution_mentor_discussion_post, iteration: iteration, author: mentor)

    notification = User::Notifications::StudentRepliedToDiscussionNotification.create!(
      user: user,
      params: {
        discussion_post: discussion_post
      }
    )
    assert_equal "#", notification.url
    assert_equal "#{user.id}-student_replied_to_discussion-DiscussionPost##{discussion_post.id}", notification.uniqueness_key
    assert_equal "#{student.handle} has added a new comment on the solution you are mentoring for #{track.title}:#{exercise.title}", notification.text  # rubocop:disable Layout/LineLength
    assert_equal :avatar, notification.image_type
    assert_equal student.avatar_url, notification.image_url
  end
end
