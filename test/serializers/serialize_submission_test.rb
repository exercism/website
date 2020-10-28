require 'test_helper'

class SerializeSubmissionTest < ActiveSupport::TestCase
  test "test submission" do
    user = create :user
    auth_token = create :user_auth_token, user: user
    solution = create :concept_solution, user: user
    submission = create :submission, tests_status: :failed, solution: solution

    expected = {
      uuid: submission.uuid,
      tests_status: 'failed',
      links: {
        cancel: Exercism::Routes.api_submission_cancellations_url(submission, auth_token: auth_token.to_s),
        submit: Exercism::Routes.api_solution_iterations_url(
          submission.solution.uuid,
          submission_id: submission.uuid,
          auth_token: auth_token.to_s
        )
      }
    }
    actual = SerializeSubmission.(submission)
    assert_equal expected, actual
  end

  test "returns nil if nil is passed in" do
    assert_nil SerializeSubmission.(nil)
  end
end
