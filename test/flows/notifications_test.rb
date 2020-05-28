require 'test_helper'

class NotificationsFlowsTest < ActiveSupport::TestCase
  test "notifications generated and sent" do
    user = create :user
    solution = create :practice_solution, user: user
    mentor = create :user
    request = create :solution_mentor_request, solution: solution
    iteration = create :iteration, solution: solution
    content_markdown = "This\nis some sort of\nreply"

    Mentor::StartDiscussion.(mentor, request, iteration, content_markdown)

    assert_equal 1, user.notifications.count
  end
end
