class SerializeSubmission
  include Mandate

  initialize_with :submission

  def call
    return unless submission

    solution_uuid = submission.solution.uuid

    {
      id: submission.uuid,
      tests_status: submission.tests_status,
      links: {
        cancel: Exercism::Routes.api_solution_submission_cancellations_url(solution_uuid, submission),
        submit: Exercism::Routes.api_solution_iterations_url(solution_uuid, submission_id: submission.uuid),
        test_run: Exercism::Routes.api_solution_submission_test_run_url(solution_uuid, submission.uuid),
        initial_files: Exercism::Routes.api_solution_initial_files_url(solution_uuid)
      }
    }
  end
end
