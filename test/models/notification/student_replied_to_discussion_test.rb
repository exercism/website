require 'test_helper'

class Notification::StudentRepliedToDiscussionNotificationTest < ActiveSupport::TestCase
  test "text is valid" do
    track = create :track
    exercise = create :practice_exercise, track: track
    solution = create :practice_solution, exercise: exercise
    iteration = create :iteration, solution: solution
    mentor = create(:user)
    discussion_post = create(:iteration_discussion_post, iteration: iteration, user: mentor)
    
    notification = Notification::StudentRepliedToDiscussionNotification.create!(
      user: mentor,
      params: { 
        discussion_post: discussion_post 
      }
    )
    assert_equal "#{solution.user.handle} has added a new comment on the solution you are mentoring for #{track.title}:#{exercise.title}", notification.text
  end
end


