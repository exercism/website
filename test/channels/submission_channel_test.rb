require "test_helper"

class SubmissionChannelTest < ActionCable::Channel::TestCase
  test ".broadcast! broadcasts submission" do
    solution = create :practice_solution
    submission = create :submission, solution: solution

    assert_broadcast_on(
      'submission',
      submission: {
        id: submission.uuid,
        tests_status: "not_queued",
        links: {
          cancel: Exercism::Routes.api_submission_cancellations_url(submission),
          submit: Exercism::Routes.api_solution_iterations_url(submission.solution.uuid, submission_id: submission.uuid),
          test_run: Exercism::Routes.api_submission_test_run_url(submission.uuid),
          initial_files: Exercism::Routes.api_solution_initial_files_url(submission.solution.uuid)
        }
      }
    ) do
      SubmissionChannel.broadcast!(submission)
    end
  end
end
