class SerializeSubmission
  include Mandate

  initialize_with :submission

  def call
    return unless submission

    {
      uuid: submission.uuid,
      tests_status: submission.tests_status,
      links: {
        cancel: Exercism::Routes.api_submission_cancellations_url(submission),
        submit: Exercism::Routes.api_solution_iterations_url(
          submission.solution.uuid,
          submission_id: submission.uuid
        ),
        test_run: Exercism::Routes.api_submission_test_run_url(
          submission.uuid
        )
      }
    }
  end

  private
  def user
    submission.solution.user
  end
end
