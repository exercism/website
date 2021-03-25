require "test_helper"

class MentorRequestFlowsTest < ActiveSupport::TestCase
  test "request and get a mentor" do
    user = create :user
    mentor = create :user

    solution = create :practice_solution, user: user
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    request = Mentor::Request::Create.(solution, "Some text")

    Mentor::Request::Lock.(request, mentor)
    assert request.reload.locked?

    discussion = Mentor::Discussion::Create.(
      mentor,
      request,
      iteration.idx,
      "This is great!! Why do you even need a mentor?"
    )
    assert_equal 1, solution.mentor_discussions.size
    assert_equal 1, discussion.posts.size

    Mentor::Discussion::ReplyByStudent.(discussion, iteration, "Well, because I don't know ALL the answers.")
    assert_equal 2, discussion.posts.size

    Mentor::Discussion::ReplyByMentor.(discussion, iteration, "You know enough. Believe in yourself.")
    assert_equal 3, discussion.posts.size
  end
end
