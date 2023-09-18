require_relative '../base_test_case'

class API::Solutions::SubmissionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solution_submissions_path, args: 1, method: :post

  ###
  # CREATE
  ###
  test "create should 404 if the solution doesn't exist" do
    setup_user
    post api_solution_submissions_path(999), headers: @headers, as: :json
    assert_response :not_found
  end

  test "create should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    post api_solution_submissions_path(solution.uuid), headers: @headers, as: :json
    assert_response :forbidden
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should return serialized submission" do
    setup_user
    solution = create :concept_solution, user: @current_user

    post api_solution_submissions_path(solution.uuid),
      params: {
        files: [{ filename: "foo", content: "bar" }]
      },
      headers: @headers,
      as: :json

    assert_response :created
    expected = {
      submission: {
        uuid: Submission.last.uuid,
        tests_status: 'queued',
        links: {
          cancel: Exercism::Routes.cancel_api_solution_submission_test_run_url(solution.uuid, Submission.last),
          submit: Exercism::Routes.api_solution_iterations_url(
            Submission.last.solution.uuid,
            submission_uuid: Submission.last.uuid
          ),
          test_run: Exercism::Routes.api_solution_submission_test_run_url(solution.uuid, Submission.last.uuid),
          ai_help: Exercism::Routes.api_solution_submission_ai_help_path(solution.uuid, Submission.last.uuid),
          initial_files: Exercism::Routes.api_solution_initial_files_url(solution.uuid),
          last_iteration_files: Exercism::Routes.api_solution_last_iteration_files_url(solution.uuid)
        }
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create submission" do
    setup_user
    solution = create :concept_solution, user: @current_user

    files = [
      { filename: "foo", content: "bar" },
      { filename: "bar", content: "foo" }
    ]
    Submission::Create.expects(:call).with(solution, files, :api).returns(create(:submission))

    post api_solution_submissions_path(solution.uuid),
      params: { files: },
      headers: @headers,
      as: :json

    assert_response :created
  end

  test "create is rate limited" do
    setup_user

    beginning_of_minute = Time.current.beginning_of_minute
    travel_to beginning_of_minute

    solution = create :concept_solution, user: @current_user

    12.times do |idx|
      post api_solution_submissions_path(solution.uuid),
        params: { files: [{ filename: "foo", content: "bar #{idx}" }] },
        headers: @headers,
        as: :json

      assert_response :success
    end

    post api_solution_submissions_path(solution.uuid),
      params: { files: [{ filename: "foo", content: "bar 12" }] },
      headers: @headers,
      as: :json

    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to beginning_of_minute + 1.minute

    post api_solution_submissions_path(solution.uuid),
      params: { files: [{ filename: "foo", content: "bar 13" }] },
      headers: @headers,
      as: :json

    assert_response :success
  end

  test "returns error if submission is too large" do
    filename = "subdir/foobar.rb"
    content = "a" * (1.megabyte + 1)

    setup_user
    solution = create :concept_solution, user: @current_user

    post api_solution_submissions_path(solution.uuid),
      params: { files: [{ filename:, content: }] },
      headers: @headers,
      as: :json

    assert_response :bad_request
    expected = { error: {
      type: "file_too_large",
      message: I18n.t("api.errors.file_too_large")
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should catch duplicate submission" do
    setup_user
    solution = create :concept_solution, user: @current_user

    Submission::Create.expects(:call).raises(DuplicateSubmissionError)

    post api_solution_submissions_path(solution.uuid),
      params: { files: [] },
      headers: @headers,
      as: :json

    assert_response :bad_request
    expected = { error: {
      type: "duplicate_submission",
      message: I18n.t('api.errors.duplicate_submission')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
end
