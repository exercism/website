require 'test_helper'

class Notifications::MentorStartedDiscussionNotificationTest < ActiveSupport::TestCase
  test "uniqueness_key" do
    user = create :user
    discussion = create(:solution_mentor_discussion)
    discussion_post = create(:solution_mentor_discussion_post)

    notification = Notifications::MentorStartedDiscussionNotification.create!(
      user: user,
      params: {
        discussion: discussion,
        discussion_post: discussion_post
      }
    )
    key = "#{user.id}-mentor_started_discussion-Discussion##{discussion.id}"
    assert_equal key, notification.uniqueness_key
  end

  test "text is valid" do
    track = create :track
    exercise = create :practice_exercise, track: track
    mentor = create(:user)
    discussion = create(:solution_mentor_discussion, solution: create(:practice_solution, exercise: exercise), mentor: mentor)
    discussion_post = create(:solution_mentor_discussion_post, discussion: discussion)

    notification = Notifications::MentorStartedDiscussionNotification.create!(
      user: create(:user),
      params: {
        discussion: discussion,
        discussion_post: discussion_post
      }
    )
    assert_equal "#{mentor.handle} has started mentoring your solution to #{track.title}:#{exercise.title}", notification.text
  end
end
