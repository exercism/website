require 'test_helper'

class NotificationsFlowsTest < ActiveSupport::TestCase
  test "notifications generated and sent" do
    user = create :user
    solution = create :practice_solution, user: user
    mentor = create :user
    request = create :solution_mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission
    content_markdown = "This\nis some sort of\nreply"

    discussion = Solution::MentorDiscussion::Create.(mentor, request, iteration.idx, content_markdown)
    assert_equal 1, user.notifications.count

    Solution::MentorDiscussion::ReplyByStudent.(discussion, iteration, "This is great")
    assert_equal 1, mentor.notifications.count
    assert_equal 1, mentor.notifications.unread.count

    Solution::MentorDiscussion::ReplyByMentor.(discussion, iteration, "This is great")
    assert_equal 2, user.notifications.count
    assert_equal 2, user.notifications.unread.count

    User::Notification.where(user: mentor).first.read!
    assert_equal 1, mentor.notifications.count
    assert_equal 0, mentor.notifications.unread.count
    assert_equal 1, mentor.notifications.read.count

    User::Notification.where(user: user).first.read!
    assert_equal 2, user.notifications.count
    assert_equal 1, user.notifications.unread.count
    assert_equal 1, user.notifications.read.count
  end
end
