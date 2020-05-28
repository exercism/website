require 'test_helper'

class Notification::MentorDiscussionStartedNotificationTest < ActiveSupport::TestCase
  test "i18n for mentor_discussion_started" do
    track = create :track
    exercise = create :practice_exercise, track: track
    mentor = create(:user)
    discussion = create(:solution_mentor_discussion, solution: create(:practice_solution, exercise: exercise), mentor: mentor)
    
    notification = Notification::MentorDiscussionStartedNotification.create!(
      user: create(:user),
      params: { discussion: discussion}
    )
    assert_equal "#{mentor.handle} has started mentoring your solution to #{track.title}:#{exercise.title}", notification.text
  end
end
