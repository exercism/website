require "test_helper"

class Mentor::StartDiscussionTest < ActiveSupport::TestCase
  test "creates discussion" do
    mentor = create :user
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    iteration = create :iteration, solution: solution
    content_markdown = "Some interesting info"

    Mentor::StartDiscussion.(mentor, request, iteration, content_markdown)

    assert_equal 1, Solution::MentorDiscussion.count

    discussion = Solution::MentorDiscussion.last
    assert_equal mentor, discussion.mentor
    assert_equal request, discussion.request
    assert_equal request.solution, discussion.solution

    assert_equal 1, discussion.posts.count
    assert_equal content_markdown, discussion.posts.first.content_markdown
    assert_equal mentor, discussion.posts.first.user
  end

  test "creates notification" do
    request = create :solution_mentor_request
    iteration = create :iteration, solution: request.solution
    user = request.solution.user
    Mentor::StartDiscussion.(create(:user), request, iteration, "foobar")

    assert_equal 1, user.notifications.size
    assert_equal Notification::MentorDiscussionStartedNotification, user.notifications.first.class
  end

  test "fulfils request" do
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    iteration = create :iteration, solution: solution

    assert_equal :pending, request.status
    Mentor::StartDiscussion.(create(:user), request, iteration, "foo")
    assert_equal :fulfilled, request.reload.status
  end

  test "discussion not created if request fails" do
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    iteration = create :iteration, solution: solution

    request.expects(:fulfilled!).raises

    begin
      Mentor::StartDiscussion.(create(:user), request, iteration, "foo")
    rescue
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorDiscussion.count
  end

  test "request not fullfiled if discussion fails" do
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    iteration = create :iteration, solution: solution

    Solution::MentorDiscussion.expects(:create!).raises

    begin
      Mentor::StartDiscussion.(create(:user), request, iteration, "foo")
    rescue
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorDiscussion.count
  end

  test "request not fullfiled if content is blank" do
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    iteration = create :iteration, solution: solution

    begin
      Mentor::StartDiscussion.(create(:user), request, iteration, " \n ")
    rescue
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorDiscussion.count
  end

  test "request not fullfiled if locked" do
    mentor = create :user
    solution = create :practice_solution
    request = create :solution_mentor_request, solution: solution
    request.expects(:lockable_by?).with(mentor).returns(false)
    iteration = create :iteration, solution: solution

    assert_raises SolutionLockedByAnotherMentorError do
      Mentor::StartDiscussion.(mentor, request, iteration, "foobar")
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorDiscussion.count
  end
end
