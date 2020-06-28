require 'test_helper'

class Notifications::MentorStartedDiscussionNotificationTest < ActiveSupport::TestCase
  test "anti_duplicate_key" do
    user = create :user
    discussion = create(:solution_mentor_discussion)
    discussion_post = create(:iteration_discussion_post)

    notification = Notifications::MentorStartedDiscussionNotification.create!(
      user: user,
      params: {
        discussion: discussion,
        discussion_post: discussion_post
      }
    )
    key = "#{user.id}-mentor_started_discussion-Discussion##{discussion.id}"
    assert_equal key, notification.anti_duplicate_key
  end

  test "text is valid" do
    track = create :track
    exercise = create :practice_exercise, track: track
    mentor = create(:user)
    discussion = create(:solution_mentor_discussion, solution: create(:practice_solution, exercise: exercise), mentor: mentor)
    discussion_post = create(:iteration_discussion_post, source: discussion)

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
