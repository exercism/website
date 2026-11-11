require "test_helper"

class SubmissionChannelTest < ActionCable::Channel::TestCase
  test "subscribes a maintainer" do
    stub_connection(current_user: create(:user, :maintainer))

    subscribe

    assert subscription.confirmed?
    assert_has_stream "submission"
  end

  test "rejects a user who is not a maintainer" do
    stub_connection(current_user: create(:user))

    subscribe

    assert subscription.rejected?
    assert_no_streams
  end

  test "rejects an anonymous connection" do
    stub_connection(current_user: nil)

    subscribe

    assert subscription.rejected?
    assert_no_streams
  end

  test ".broadcast! broadcasts submission" do
    solution = create :practice_solution
    submission = create(:submission, solution:)

    assert_broadcast_on(
      'submission',
      submission: {
        uuid: submission.uuid,
        tests_status: "not_queued",
        links: {
          cancel: Exercism::Routes.cancel_api_solution_submission_test_run_url(solution.uuid, submission),
          submit: Exercism::Routes.api_solution_iterations_url(submission.solution.uuid, submission_uuid: submission.uuid),
          test_run: Exercism::Routes.api_solution_submission_test_run_url(solution.uuid, submission.uuid),
          initial_files: Exercism::Routes.api_solution_initial_files_url(solution.uuid),
          last_iteration_files: Exercism::Routes.api_solution_last_iteration_files_url(solution.uuid)
        }
      }
    ) do
      SubmissionChannel.broadcast!(submission)
    end
  end
end
