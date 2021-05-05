require_relative './base_test_case'

class API::IterationsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solution_iterations_path, args: 1, method: :post
  guard_incorrect_token! :latest_status_api_solution_iterations_path, args: 1

  ###
  # latst_status
  ###
  test "latest_status should 404 if the solution doesn't exist" do
    setup_user
    get latest_status_api_solution_iterations_path(999), headers: @headers, as: :json
    assert_response 404
  end

  test "latest_status should 404 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    get latest_status_api_solution_iterations_path(solution.uuid), headers: @headers, as: :json
    assert_response 403
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
  ###
  # CREATE
  ###
  test "create should 404 if the solution doesn't exist" do
    setup_user
    post api_solution_iterations_path(999, submission_id: create(:submission)), headers: @headers, as: :json
    assert_response 404
  end

  test "create should 404 if the submission doesn't exist" do
    setup_user
    post api_solution_iterations_path(create(:concept_solution).uuid, submission_id: 999), headers: @headers, as: :json
    assert_response 403
  end

  test "create should 404 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    submission = create :submission, solution: solution
    post api_solution_iterations_path(solution.uuid, submission_id: submission.uuid), headers: @headers, as: :json
    assert_response 403
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should 404 if the submission doesn't belong to the solution" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create :submission, track: solution.track
    post api_solution_iterations_path(solution.uuid, submission_id: submission.uuid), headers: @headers, as: :json
    assert_response 404
    expected = { error: {
      type: "submission_not_found",
      message: I18n.t('api.errors.submission_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should return serialized iteration" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create :submission, solution: solution

    post api_solution_iterations_path(solution.uuid, submission_id: submission.uuid),
      headers: @headers,
      as: :json

    assert_response :success
    expected = {
      iteration: SerializeIteration.(Iteration.last)
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create submission" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create :submission, solution: solution

    Iteration::Create.expects(:call).with(solution, submission).returns(create(:iteration, submission: submission))

    post api_solution_iterations_path(solution.uuid, submission_id: submission.uuid),
      headers: @headers,
      as: :json

    assert_response :success
  end
end
