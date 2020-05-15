require "test_helper"

class MentorRequestFlowsTest < ActiveSupport::TestCase
  test "request and get a mentor" do
    user = create :user, credits: 5
    mentor = create :user

    solution = create :practice_solution, user: user
    iteration = create :iteration, solution: solution

    request = User::RequestMentor.(solution, 3, :code_review, "")
    assert_equal 2, user.reload.credits

    Mentor::StartConversation.(mentor, request)
  end
end
