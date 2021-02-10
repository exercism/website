require 'test_helper'

class Notifications::MentorStartedDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user
    mentor = create :user
    solution = create :concept_solution
    exercise = solution.exercise
    track = solution.track
    discussion = create(:solution_mentor_discussion, mentor: mentor, solution: solution)
    discussion_post = create(:solution_mentor_discussion_post)

    notification = Notifications::MentorStartedDiscussionNotification.create!(
      user: user,
      params: {
        discussion: discussion,
        discussion_post: discussion_post
      }
    )
    assert_equal "#{user.id}-mentor_started_discussion-Discussion##{discussion.id}", notification.uniqueness_key
    assert_equal "<strong>#{mentor.handle}</strong> has started mentoring your solution to <strong>#{exercise.title}</strong> in <strong>#{track.title}</strong>", notification.text
  end
end
