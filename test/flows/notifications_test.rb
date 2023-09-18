require 'test_helper'

class NotificationsFlowsTest < ActiveSupport::TestCase
  test "notifications generated and sent" do
    user = create :user
    solution = create(:practice_solution, user:)
    mentor = create :user
    request = create(:mentor_request, solution:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)
    content_markdown = "This\nis some sort of\nreply"

    discussion = Mentor::Discussion::Create.(mentor, request, iteration.idx, content_markdown)
    User::Notification.last.update(status: :unread)
    assert_equal 1, user.notifications.count

    Mentor::Discussion::ReplyByStudent.(discussion, iteration, "This is great")
    User::Notification.last.update(status: :unread)
    assert_equal 1, mentor.notifications.count
    assert_equal 1, mentor.notifications.unread.count

    Mentor::Discussion::ReplyByMentor.(discussion, iteration, "This is great")
    User::Notification.last.update(status: :unread)
    assert_equal 2, user.notifications.count
    assert_equal 2, user.notifications.unread.count

    User::Notification.where(user: mentor).first.read!
    assert_equal 1, mentor.notifications.count
    refute mentor.notifications.unread.exists?
    assert_equal 1, mentor.notifications.read.count

    User::Notification.where(user:).first.read!
    assert_equal 2, user.notifications.count
    assert_equal 1, user.notifications.unread.count
    assert_equal 1, user.notifications.read.count
  end
end
