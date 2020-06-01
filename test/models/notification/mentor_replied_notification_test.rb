require 'test_helper'

class Notification::MentorRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "text is valid" do
    track = create :track
    exercise = create :practice_exercise, track: track
    solution = create :practice_solution, exercise: exercise
    iteration = create :iteration, solution: solution
    mentor = create(:user)
    discussion_post = create(:iteration_discussion_post, iteration: iteration, user: mentor)
    
    notification = Notification::MentorRepliedToDiscussionNotification.create!(
      user: create(:user),
      params: { discussion_post: discussion_post }
    )
    assert_equal "#{mentor.handle} has added a new comment on your solution to #{track.title}:#{exercise.title}", notification.text
  end
end

