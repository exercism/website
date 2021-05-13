require "test_helper"

class IterationTest < ActiveSupport::TestCase
  test "published?" do
    solution = create :concept_solution
    iteration = create :iteration, solution: solution
    other_iteration = create :iteration, solution: solution

    refute iteration.published?

    solution.update(published_at: Time.current)
    assert iteration.published?

    solution.update(published_iteration: other_iteration)
    refute iteration.published?

    solution.update(published_iteration: iteration)
    assert iteration.published?
  end

  test "broadcast broadcasts self and solution" do
    iteration = create :iteration

    IterationChannel.expects(:broadcast!).with(iteration)
    SolutionChannel.expects(:broadcast!).with(iteration.solution)

    iteration.broadcast!
  end

  test "tests_pending?" do
    assert create(:submission, tests_status: :not_queued).tests_pending?
    assert create(:submission, tests_status: :queued).tests_pending?
    refute create(:submission, tests_status: :passed).tests_pending?
    refute create(:submission, tests_status: :failed).tests_pending?
    refute create(:submission, tests_status: :errored).tests_pending?
    refute create(:submission, tests_status: :exceptioned).tests_pending?
    refute create(:submission, tests_status: :cancelled).tests_pending?
  end

  test "tests_passed?" do
    refute create(:submission, tests_status: :not_queued).tests_passed?
    refute create(:submission, tests_status: :queued).tests_passed?
    assert create(:submission, tests_status: :passed).tests_passed?
    refute create(:submission, tests_status: :failed).tests_passed?
    refute create(:submission, tests_status: :errored).tests_passed?
    refute create(:submission, tests_status: :exceptioned).tests_passed?
    refute create(:submission, tests_status: :cancelled).tests_passed?
  end

  test "status: tests pending" do
    submission = create :submission, tests_status: :queued
    submission.expects(tests_pending?: true)
    iteration = create :iteration, submission: submission

    assert iteration.status.testing?
  end

  test "status: tests failed" do
    submission = create :submission, tests_status: :queued
    submission.expects(
      tests_pending?: false,
      tests_passed?: false
    )
    iteration = create :iteration, submission: submission

    assert iteration.status.tests_failed?
  end

  test "status: pending feedback" do
    submission = create :submission, tests_status: :queued
    submission.expects(
      tests_pending?: false,
      tests_passed?: true,
      automated_feedback_pending?: true
    )
    iteration = create :iteration, submission: submission

    assert iteration.status.analyzing?
  end

  test "status: no feedback" do
    submission = create :submission, tests_status: :queued
    submission.expects(
      tests_pending?: false,
      tests_passed?: true,
      automated_feedback_pending?: false,
      has_essential_automated_feedback?: false,
      has_actionable_automated_feedback?: false,
      has_non_actionable_automated_feedback?: false
    )
    iteration = create :iteration, submission: submission

    assert iteration.status.no_automated_feedback?
  end

  test "status: essential feedback" do
    submission = create :submission, tests_status: :queued
    submission.expects(
      tests_pending?: false,
      tests_passed?: true,
      automated_feedback_pending?: false,
      has_essential_automated_feedback?: true
    )
    iteration = create :iteration, submission: submission

    assert iteration.status.essential_automated_feedback?
  end

  test "status: actionable feedback" do
    submission = create :submission, tests_status: :queued
    submission.expects(
      tests_pending?: false,
      tests_passed?: true,
      automated_feedback_pending?: false,
      has_essential_automated_feedback?: false,
      has_actionable_automated_feedback?: true
    )
    iteration = create :iteration, submission: submission

    assert iteration.status.actionable_automated_feedback?
  end

  test "status: non_actionable feedback" do
    submission = create :submission, tests_status: :queued
    submission.expects(
      tests_pending?: false,
      tests_passed?: true,
      automated_feedback_pending?: false,
      has_essential_automated_feedback?: false,
      has_actionable_automated_feedback?: false,
      has_non_actionable_automated_feedback?: true
    )
    iteration = create :iteration, submission: submission

    assert iteration.status.non_actionable_automated_feedback?
  end

  test "delegates to submission where appropriate" do
    submission = create :submission
    iteration = create :iteration, submission: submission

    representer_feedback = mock
    analyzer_feedback = mock

    submission.stubs(
      representer_feedback: representer_feedback,
      analyzer_feedback: analyzer_feedback
    )

    assert_equal representer_feedback, iteration.representer_feedback
    assert_equal analyzer_feedback, iteration.analyzer_feedback
  end

  test "updates_solution" do
    solution = create :concept_solution

    # Sanity
    assert_equal :started, solution.status
    assert_nil solution.iteration_status

    create :iteration, solution: solution

    solution.reload
    assert_equal :iterated, solution.status
    assert_equal :testing, solution.iteration_status
  end
end
