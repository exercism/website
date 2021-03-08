require "test_helper"

class Solution::MentorRequest::CreateTest < ActiveSupport::TestCase
  test "creates request" do
    user = create :user
    solution = create :practice_solution, user: user
    comment = "Please help with this"

    Solution::MentorRequest::Create.(solution, comment)

    assert_equal 1, Solution::MentorRequest.count

    request = Solution::MentorRequest.last
    assert_equal solution, request.solution
    assert_equal comment, request.comment
  end

  test "returns existing in progress request" do
    user = create :user
    solution = create :practice_solution, user: user
    existing_request = create :solution_mentor_request, status: :pending, solution: solution
    new_request = Solution::MentorRequest::Create.(solution, nil, nil)
    assert_equal existing_request, new_request
  end

  test "creates new request if there is a fulfilled one" do
    existing_request = create :solution_mentor_request, status: :fulfilled
    new_request = Solution::MentorRequest::Create.(existing_request.solution, "")
    refute_equal existing_request, new_request
  end
end
