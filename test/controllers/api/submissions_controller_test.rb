require_relative './base_test_case'

class API::SubmissionsControllerTest < API::BaseTestCase
  ###
  # CREATE
  ###
  test "create should return 401 with incorrect token" do
    post api_solution_submissions_path(1), headers: @headers, as: :json
    assert_response 401
  end

  test "create should 404 if the solution doesn't exist" do
    setup_user
    post api_solution_submissions_path(999), headers: @headers, as: :json
    assert_response 404
  end

  test "create should 404 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    post api_solution_submissions_path(solution.uuid), headers: @headers, as: :json
    assert_response 403
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

    assert_response :success
    expected = {
      submission: {
        id: Submission.last.uuid,
        tests_status: 'queued',
        representation_status: 'not_queued',
        analysis_status: 'not_queued',
        links: {
          cancel: Exercism::Routes.api_submission_cancellations_url(Submission.last),
          submit: Exercism::Routes.api_solution_iterations_url(
            Submission.last.solution.uuid,
            submission_id: Submission.last.uuid
          ),
          test_run: Exercism::Routes.api_submission_test_run_url(Submission.last.uuid),
          initial_files: Exercism::Routes.api_solution_initial_files_url(solution.uuid)
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
      params: { files: files },
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
      params: { files: [{ filename: filename, content: content }] },
      headers: @headers,
      as: :json

    assert_response 400
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

    assert_response 400
    expected = { error: {
      type: "duplicate_submission",
      message: I18n.t('api.errors.duplicate_submission')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
end
