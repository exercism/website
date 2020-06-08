require "test_helper"

class User::RequestMentorTest < ActiveSupport::TestCase
  test "creates request" do
    user = create :user
    solution = create :practice_solution, user: user
    type = :code_review
    comment = "Please help with this"

    User::RequestMentor.(solution, type, comment)

    assert_equal 1, Solution::MentorRequest.count

    request = Solution::MentorRequest.last
    assert_equal solution, request.solution
    assert_equal type, request.type
    assert_equal comment, request.comment
  end

  test "returns existing in progress request" do
    user = create :user
    solution = create :practice_solution, user: user
    existing_request = create :solution_mentor_request, status: :pending, solution: solution
    new_request = User::RequestMentor.(solution, nil, nil)
    assert_equal existing_request, new_request
  end

  test "creates new request if there is a fulfilled one" do
    existing_request = create :solution_mentor_request, status: :fulfilled
    new_request = User::RequestMentor.(existing_request.solution, :code_review, "")
    refute_equal existing_request, new_request
  end

end

