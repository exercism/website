require "test_helper"

class MentorRequestFlowsTest < ActiveSupport::TestCase
  test "request and get a mentor" do
    user = create :user, credits: 5
    mentor = create :user

    solution = create :practice_solution, user: user
    iteration = create :iteration, solution: solution

    request = User::RequestMentor.(solution, 3, :code_review, "")
    assert_equal 2, user.reload.credits

    Mentor::LockRequest.(mentor, request)
    assert request.reload.locked?

    Mentor::StartDiscussion.(mentor, request, iteration, "This is great!! Why do you even need a mentor?")
    assert_equal 1, solution.mentor_discussions.size
    assert_equal 1, solution.mentor_discussions.first.posts.size
  end
end
