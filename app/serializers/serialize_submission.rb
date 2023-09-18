class SerializeSubmission
  include Mandate

  initialize_with :submission

  def call
    return unless submission

    solution_uuid = submission.solution.uuid

    {
      uuid: submission.uuid,
      tests_status: submission.tests_status,
      links: {
        cancel: Exercism::Routes.cancel_api_solution_submission_test_run_url(solution_uuid, submission),
        submit: Exercism::Routes.api_solution_iterations_url(solution_uuid, submission_uuid: submission.uuid),
        test_run: Exercism::Routes.api_solution_submission_test_run_url(solution_uuid, submission.uuid),
        ai_help: Exercism::Routes.api_solution_submission_ai_help_path(solution_uuid, submission.uuid),
        initial_files: Exercism::Routes.api_solution_initial_files_url(solution_uuid),
        last_iteration_files: Exercism::Routes.api_solution_last_iteration_files_url(solution_uuid)
      }
    }
  end
end
