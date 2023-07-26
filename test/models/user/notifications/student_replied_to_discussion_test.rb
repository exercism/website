require 'test_helper'

class User::Notifications::StudentRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:)
    solution = create(:practice_solution, exercise:, user:)
    student = solution.user
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)
    mentor = create(:user)
    discussion_post = create(:mentor_discussion_post, iteration:, author: mentor)

    notification = User::Notifications::StudentRepliedToDiscussionNotification.create!(
      user:,
      params: {
        discussion_post:
      }
    )
    assert_equal "#{user.id}|student_replied_to_discussion|DiscussionPost##{discussion_post.id}", notification.uniqueness_key
    assert_equal "<strong>#{student.handle}</strong> has added a new comment on the solution you are mentoring for <strong>#{exercise.title}</strong> in <strong>#{track.title}</strong>", notification.text # rubocop:disable Layout/LineLength
    assert_equal :avatar, notification.image_type
    assert_equal student.avatar_url, notification.image_url
    assert_equal discussion_post.discussion.mentor_url, notification.url
    assert_equal "/mentoring/discussions/#{discussion_post.discussion.uuid}", notification.path
  end
end
