require_relative '../base_test_case'

class API::Solutions::SubmissionTestRunsControllerTest < API::BaseTestCase
  guard_incorrect_token! :cancel_api_solution_submission_test_run_path, args: 2, method: :patch

  ###
  # CANCEL
  ###
  test "cancel should 404 if the solution doesn't exist" do
    setup_user
    solution = create :concept_solution
    patch cancel_api_solution_submission_test_run_path(solution.uuid, 999), headers: @headers, as: :json
    assert_response :not_found
  end

  test "cancel should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    submission = create(:submission, solution:)

    patch cancel_api_solution_submission_test_run_path(solution.uuid, submission.uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "submission_not_accessible",
      message: I18n.t('api.errors.submission_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "cancel should cancel submission" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create(:submission, solution:)

    ToolingJob::Cancel.expects(:call).with(submission.uuid, :test_runner)
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :representer)
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :analyzer)

    patch cancel_api_solution_submission_test_run_path(solution.uuid, submission.uuid), headers: @headers, as: :json
    assert_response :ok
  end
end
