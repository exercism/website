require 'test_helper'

class SerializeSubmissionTest < ActiveSupport::TestCase
  test "test submission" do
    user = create :user
    solution = create :concept_solution, user: user
    submission = create :submission, tests_status: :failed, solution: solution

    expected = {
      uuid: submission.uuid,
      tests_status: 'failed',
      links: {
        cancel: Exercism::Routes.api_submission_cancellations_url(submission),
        submit: Exercism::Routes.api_solution_iterations_url(submission.solution.uuid, submission_id: submission.uuid),
        test_run: Exercism::Routes.api_submission_test_run_url(submission.uuid),
        initial_files: Exercism::Routes.api_solution_initial_files_url(submission.solution.uuid)
      }
    }
    actual = SerializeSubmission.(submission)
    assert_equal expected, actual
  end

  test "returns nil if nil is passed in" do
    assert_nil SerializeSubmission.(nil)
  end
end
