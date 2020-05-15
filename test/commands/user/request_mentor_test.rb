require "test_helper"

class User::RequestMentorTest < ActiveSupport::TestCase
  test "creates request" do
    user = create :user, credits: 5
    solution = create :practice_solution, user: user
    type = :code_review
    comment = "Please help with this"
    bounty = 3

    User::RequestMentor.(solution, bounty, type, comment)

    assert_equal 1, Solution::MentorRequest.count

    request = Solution::MentorRequest.last
    assert_equal solution, request.solution
    assert_equal type, request.type
    assert_equal bounty, request.bounty
    assert_equal comment, request.comment
  end

  test "returns existing in progress request" do
    existing_request = create :solution_mentor_request, status: :pending
    new_request = User::RequestMentor.(existing_request.solution, 1, nil, nil)
    assert_equal existing_request, new_request
  end

  test "creates new request if there is a fulfilled one" do
    existing_request = create :solution_mentor_request, status: :fulfilled
    new_request = User::RequestMentor.(existing_request.solution, 1, :code_review, "")
    refute_equal existing_request, new_request
  end

end

