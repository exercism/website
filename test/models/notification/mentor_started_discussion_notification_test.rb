require 'test_helper'

class Notification::MentorStartedDiscussionNotificationTest < ActiveSupport::TestCase
  test "text is valid" do
    track = create :track
    exercise = create :practice_exercise, track: track
    mentor = create(:user)
    discussion = create(:solution_mentor_discussion, solution: create(:practice_solution, exercise: exercise), mentor: mentor)
    discussion_post = create(:iteration_discussion_post, source: discussion)
    
    notification = Notification::MentorStartedDiscussionNotification.create!(
      user: create(:user),
      params: { 
        discussion: discussion,
        discussion_post: discussion_post
      }
    )
    assert_equal "#{mentor.handle} has started mentoring your solution to #{track.title}:#{exercise.title}", notification.text
  end
end
