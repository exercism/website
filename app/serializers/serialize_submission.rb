class SerializeSubmission
  include Mandate

  initialize_with :submission

  def call
    {
      uuid: submission.uuid,
      tests_status: submission.tests_status,
      links: {
        cancel: Exercism::Routes.api_submission_cancellations_url(submission, auth_token: user.auth_tokens.first.to_s)
      }
    }
  end

  private
  def user
    submission.solution.user
  end
end
