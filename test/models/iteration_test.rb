require "test_helper"

class IterationTest < ActiveSupport::TestCase
  test "delegates to submission where appropriate" do
    submission = create :submission
    iteration = create :iteration, submission: submission

    tests_status = mock
    automated_feedback_status = mock
    automated_feedback = mock

    submission.stubs(
      tests_status: tests_status,
      automated_feedback_status: automated_feedback_status,
      automated_feedback: automated_feedback
    )

    assert_equal tests_status, iteration.tests_status
    assert_equal automated_feedback_status, iteration.automated_feedback_status
    assert_equal automated_feedback, iteration.automated_feedback
  end
end
