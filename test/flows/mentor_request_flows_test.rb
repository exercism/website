require "test_helper"

class MentorRequestFlowsTest < ActiveSupport::TestCase
  test "request and get a mentor" do
    user = create :user
    mentor = create :user

    solution = create :practice_solution, user: user
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    request = Solution::MentorRequest::Create.(solution, :code_review, "")

    Solution::MentorRequest::Lock.(request, mentor)
    assert request.reload.locked?

    discussion = Solution::MentorDiscussion::Create.(
      mentor,
      request,
      iteration.idx,
      "This is great!! Why do you even need a mentor?"
    )
    assert_equal 1, solution.mentor_discussions.size
    assert_equal 1, discussion.posts.size

    Solution::MentorDiscussion::ReplyByStudent.(discussion, iteration.idx, "Well, because I don't know ALL the answers.")
    assert_equal 2, discussion.posts.size

    Solution::MentorDiscussion::ReplyByMentor.(discussion, iteration.idx, "You know enough. Believe in yourself.")
    assert_equal 3, discussion.posts.size
  end
end
