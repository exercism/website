require "test_helper"

class Solution::MentorDiscussion::CreateTest < ActiveSupport::TestCase
  test "creates discussion" do
    mentor = create :user
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission
    content_markdown = "Some interesting info"

    Solution::MentorDiscussion::Create.(mentor, request, iteration.idx, content_markdown)

    assert_equal 1, Solution::MentorDiscussion.count

    discussion = Solution::MentorDiscussion.last
    assert_equal mentor, discussion.mentor
    assert_equal request, discussion.request
    assert_equal request.solution, discussion.solution

    assert_equal 1, discussion.posts.count
    assert_equal content_markdown, discussion.posts.first.content_markdown
    assert_equal mentor, discussion.posts.first.author
  end

  test "creates notification" do
    request = create :solution_mentor_request
    submission = create :submission, solution: request.solution
    iteration = create :iteration, submission: submission
    user = request.solution.user
    Solution::MentorDiscussion::Create.(create(:user), request, iteration.idx, "foobar")

    assert_equal 1, user.notifications.size
    assert_equal Notifications::MentorStartedDiscussionNotification, Notification.where(user: user).first.class
  end

  test "fulfils request" do
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    assert_equal :pending, request.status
    Solution::MentorDiscussion::Create.(create(:user), request, iteration.idx, "foo")
    assert_equal :fulfilled, request.reload.status
  end

  test "discussion not created if request fails" do
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    request.expects(:fulfilled!).raises(RuntimeError)

    begin
      Solution::MentorDiscussion::Create.(create(:user), request, iteration.idx, "foo")
    rescue RuntimeError
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorDiscussion.count
  end

  test "request not fullfiled if discussion fails" do
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    Solution::MentorDiscussion.expects(:create!).raises(RuntimeError)

    begin
      Solution::MentorDiscussion::Create.(create(:user), request, iteration.idx, "foo")
    rescue RuntimeError
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorDiscussion.count
  end

  test "request not fullfiled if content is blank" do
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    begin
      Solution::MentorDiscussion::Create.(create(:user), request, iteration.idx, " \n ")
    rescue ActiveRecord::RecordInvalid
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorDiscussion.count
  end

  test "request not fullfiled if locked" do
    mentor = create :user
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    request.expects(:lockable_by?).with(mentor).returns(false)
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    assert_raises SolutionLockedByAnotherMentorError do
      Solution::MentorDiscussion::Create.(mentor, request, iteration.idx, "foobar")
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorDiscussion.count
  end
end
