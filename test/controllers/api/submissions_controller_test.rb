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
        uuid: Submission.last.uuid,
        tests_status: 'queued',
        links: {
          cancel: Exercism::Routes.api_submission_cancellations_url(
            Submission.last,
            auth_token: @current_user.auth_tokens.first.to_s
          ),
          submit: Exercism::Routes.api_solution_iterations_url(
            Submission.last.solution.uuid,
            submission_id: Submission.last.uuid,
            auth_token: @current_user.auth_tokens.first.to_s
          )
        },
        test_run: nil
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create submission" do
    setup_user
    solution = create :concept_solution, user: @current_user

    params_files = [
      { filename: "foo", content: "bar" },
      { filename: "bar", content: "foo" }
    ]
    files = mock
    Submission::PrepareMappedFiles.expects(:call).with({ "foo" => "bar", "bar" => "foo" }).returns(files)
    Submission::Create.expects(:call).with(solution, files, :api).returns(create(:submission))

    post api_solution_submissions_path(solution.uuid),
      params: { files: params_files },
      headers: @headers,
      as: :json

    assert_response :success
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
