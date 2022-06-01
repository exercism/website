require "test_helper"

class Mentor::Discussion::CreateTest < ActiveSupport::TestCase
  test "creates discussion" do
    freeze_time do
      mentor = create :user
      solution = create :practice_solution
      request = create :mentor_request, solution: solution
      submission = create :submission, solution: solution
      iteration = create :iteration, submission: submission
      content_markdown = "Some interesting info"

      Mentor::Discussion::Create.(mentor, request, iteration.idx, content_markdown)

      assert_equal 1, Mentor::Discussion.count

      discussion = Mentor::Discussion.last
      assert_equal mentor, discussion.mentor
      assert_equal request, discussion.request
      assert_equal request.solution, discussion.solution
      assert_equal Time.current, discussion.awaiting_student_since
      assert_nil discussion.awaiting_mentor_since

      assert_equal 1, discussion.posts.count
      assert_equal content_markdown, discussion.posts.first.content_markdown
      assert_equal mentor, discussion.posts.first.author
    end
  end

  test "creates notification" do
    request = create :mentor_request
    submission = create :submission, solution: request.solution
    iteration = create :iteration, submission: submission
    user = request.solution.user
    Mentor::Discussion::Create.(create(:user), request, iteration.idx, "foobar")

    assert_equal 1, user.notifications.size
    assert_equal User::Notifications::MentorStartedDiscussionNotification, User::Notification.where(user:).first.class
  end

  test "updates num_discussions on relationship record" do
    request = create :mentor_request
    submission = create :submission, solution: request.solution
    iteration = create :iteration, submission: submission
    student = request.solution.user
    mentor = create :user
    Mentor::Discussion::Create.(mentor, request, iteration.idx, "foobar")

    rel = Mentor::StudentRelationship.find_by!(mentor:, student:)
    assert_equal 1, rel.num_discussions
    refute rel.favorited?
  end

  test "fulfils request" do
    solution = create :practice_solution
    request = create :mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    assert_equal :pending, request.status
    Mentor::Discussion::Create.(create(:user), request, iteration.idx, "foo")
    assert_equal :fulfilled, request.reload.status
  end

  test "discussion not created if request fails" do
    solution = create :practice_solution
    request = create :mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    request.expects(:fulfilled!).raises(RuntimeError)

    begin
      Mentor::Discussion::Create.(create(:user), request, iteration.idx, "foo")
    rescue RuntimeError
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Mentor::Discussion.count
  end

  test "request not fullfiled if discussion fails" do
    solution = create :practice_solution
    request = create :mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    Mentor::Discussion.expects(:create!).raises(RuntimeError)

    begin
      Mentor::Discussion::Create.(create(:user), request, iteration.idx, "foo")
    rescue RuntimeError
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Mentor::Discussion.count
  end

  test "request not fullfiled if content is blank" do
    solution = create :practice_solution
    request = create :mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    begin
      Mentor::Discussion::Create.(create(:user), request, iteration.idx, " \n ")
    rescue ActiveRecord::RecordInvalid
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Mentor::Discussion.count
  end

  test "request not fullfiled if locked" do
    mentor = create :user
    solution = create :practice_solution
    request = create :mentor_request, solution: solution
    request.expects(:lockable_by?).with(mentor).returns(false)
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    assert_raises SolutionLockedByAnotherMentorError do
      Mentor::Discussion::Create.(mentor, request, iteration.idx, "foobar")
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Mentor::Discussion.count
  end

  test "request not fullfiled if mentoring own solution" do
    user = create :user
    solution = create :practice_solution, user: user
    request = create :mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission

    assert_raises StudentCannotMentorThemselvesError do
      Mentor::Discussion::Create.(user, request, iteration.idx, "foobar")
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Mentor::Discussion.count
  end

  test "removes locks" do
    mentor = create :user
    solution = create :practice_solution
    request = create :mentor_request, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, submission: submission
    content_markdown = "Some interesting info"
    create :mentor_request_lock, request: request, locked_by: mentor

    Mentor::Discussion::Create.(mentor, request, iteration.idx, content_markdown)

    assert_empty Mentor::RequestLock.where(request:)
  end
end
