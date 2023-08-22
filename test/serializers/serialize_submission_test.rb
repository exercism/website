require 'test_helper'

class SerializeSubmissionTest < ActiveSupport::TestCase
  test "test submission" do
    user = create :user
    solution = create(:concept_solution, user:)
    submission = create :submission, solution:,
      tests_status: :failed,
      representation_status: :generated,
      analysis_status: :completed

    expected = {
      uuid: submission.uuid,
      tests_status: 'failed',
      links: {
        cancel: Exercism::Routes.cancel_api_solution_submission_test_run_url(submission.solution.uuid, submission),
        submit: Exercism::Routes.api_solution_iterations_url(submission.solution.uuid, submission_uuid: submission.uuid),
        test_run: Exercism::Routes.api_solution_submission_test_run_url(submission.solution.uuid, submission.uuid),
        ai_help: Exercism::Routes.api_solution_submission_ai_help_path(submission.solution.uuid, submission.uuid),
        initial_files: Exercism::Routes.api_solution_initial_files_url(submission.solution.uuid),
        last_iteration_files: Exercism::Routes.api_solution_last_iteration_files_url(submission.solution.uuid)
      }
    }
    actual = SerializeSubmission.(submission)
    assert_equal expected, actual
  end

  test "returns nil if nil is passed in" do
    assert_nil SerializeSubmission.(nil)
  end
end
