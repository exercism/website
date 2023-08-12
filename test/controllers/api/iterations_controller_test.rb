require_relative './base_test_case'

class API::IterationsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solution_iterations_path, args: 1, method: :post
  guard_incorrect_token! :api_solution_iteration_path, args: 2, method: :delete
  guard_incorrect_token! :latest_api_solution_iterations_path, args: 1
  guard_incorrect_token! :latest_status_api_solution_iterations_path, args: 1
  guard_incorrect_token! :automated_feedback_api_solution_iteration_path, args: 2

  ###
  # latest
  ###
  test "latest should 404 if the solution doesn't exist" do
    setup_user
    get latest_api_solution_iterations_path(999), headers: @headers, as: :json
    assert_response :not_found
  end

  test "latest should 404 if no iteration exist" do
    setup_user
    solution = create :concept_solution, user: @current_user

    get latest_api_solution_iterations_path(solution.uuid), headers: @headers, as: :json
    assert_response :not_found
  end

  test "latest should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    get latest_api_solution_iterations_path(solution.uuid), headers: @headers, as: :json
    assert_response :forbidden
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "latest should return latest iteration" do
    setup_user
    solution = create :concept_solution, user: @current_user
    create(:iteration, solution:)
    it_2 = create(:iteration, solution:)

    get latest_api_solution_iterations_path(solution.uuid), headers: @headers, as: :json
    assert_response :ok

    expected = { iteration: SerializeIteration.(it_2) }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "latest should return latest iteration even if it was deleted" do
    setup_user
    solution = create :concept_solution, user: @current_user
    create(:iteration, solution:)
    it_2 = create :iteration, solution:, deleted_at: Time.current

    get latest_api_solution_iterations_path(solution.uuid), headers: @headers, as: :json
    assert_response :ok

    expected = { iteration: SerializeIteration.(it_2) }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "latest allows sideloading automated feedback" do
    setup_user
    solution = create :concept_solution, user: @current_user
    create(:iteration, solution:)
    submission = create :submission, solution:,
      tests_status: :passed,
      representation_status: :queued,
      analysis_status: :queued
    create :submission_analysis, submission:, data: {
      comments: [
        { type: "informative", comment: "ruby.two-fer.splat_args" },
        { type: "essential", comment: "ruby.two-fer.splat_args" }
      ]
    }
    it_2 = create(:iteration, submission:)

    get latest_api_solution_iterations_path(solution.uuid, sideload: [:automated_feedback]), headers: @headers, as: :json
    assert_response :ok

    expected = { iteration: SerializeIteration.(it_2.reload, sideload: [:automated_feedback]) }
    expected[:iteration][:analyzer_feedback][:comments][0][:type] = 'essential'
    expected[:iteration][:analyzer_feedback][:comments][1][:type] = 'informative'
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ###
  # latest_status
  ###
  test "latest_status should 404 if the solution doesn't exist" do
    setup_user
    get latest_status_api_solution_iterations_path(999), headers: @headers, as: :json
    assert_response :not_found
  end

  test "latest_status should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    get latest_status_api_solution_iterations_path(solution.uuid), headers: @headers, as: :json
    assert_response :forbidden
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "latest_status should be correct for normal iteration" do
    setup_user
    solution = create :concept_solution, user: @current_user
    it_1 = create(:iteration, solution:)
    it_2 = create(:iteration, solution:)
    it_1.submission.update(tests_status: :passed)

    # Sanity
    assert_equal 'no_automated_feedback', it_1.status.to_s
    assert_equal 'untested', it_2.status.to_s

    get latest_status_api_solution_iterations_path(solution.uuid), headers: @headers, as: :json
    assert_response :ok

    expected = { status: "untested" }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "latest_status works with deleted iteration" do
    setup_user
    solution = create :concept_solution, user: @current_user
    create :iteration, solution:, deleted_at: Time.current

    get latest_status_api_solution_iterations_path(solution.uuid), headers: @headers, as: :json
    assert_response :ok

    expected = { status: "deleted" }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "latest_status should be correct for no iteration" do
    setup_user
    solution = create :concept_solution, user: @current_user

    get latest_status_api_solution_iterations_path(solution.uuid), headers: @headers, as: :json
    assert_response :ok

    expected = { status: nil }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ###
  # CREATE
  ###
  test "create should 404 if the solution doesn't exist" do
    setup_user
    post api_solution_iterations_path(999, submission_id: create(:submission)), headers: @headers, as: :json
    assert_response :not_found
  end

  test "create should 403 if the submission doesn't exist" do
    setup_user
    post api_solution_iterations_path(create(:concept_solution).uuid, submission_id: 999), headers: @headers, as: :json
    assert_response :forbidden
  end

  test "create should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    submission = create(:submission, solution:)
    post api_solution_iterations_path(solution.uuid, submission_id: submission.uuid), headers: @headers, as: :json
    assert_response :forbidden
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
    assert_response :not_found
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
    submission = create(:submission, solution:)

    post api_solution_iterations_path(solution.uuid, submission_uuid: submission.uuid),
      headers: @headers,
      as: :json

    assert_response :created
    expected = {
      iteration: SerializeIteration.(Iteration.last)
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create submission" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create(:submission, solution:)

    Iteration::Create.expects(:call).with(solution, submission).returns(create(:iteration, submission:))

    post api_solution_iterations_path(solution.uuid, submission_uuid: submission.uuid),
      headers: @headers,
      as: :json

    assert_response :created
  end

  test "create is rate limited" do
    setup_user

    beginning_of_minute = Time.current.beginning_of_minute
    travel_to beginning_of_minute

    4.times do
      submission = create :submission, user: @current_user
      post api_solution_iterations_path(submission.solution.uuid, submission_uuid: submission.uuid), headers: @headers
      assert_response :success
    end

    submission = create :submission, user: @current_user
    post api_solution_iterations_path(submission.solution.uuid, submission_uuid: submission.uuid), headers: @headers
    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to beginning_of_minute + 1.minute

    submission = create :submission, user: @current_user
    post api_solution_iterations_path(submission.solution.uuid, submission_uuid: submission.uuid), headers: @headers
    assert_response :success
  end

  ###
  # DESTROY
  ###
  test "destroy should 404 if the solution doesn't exist" do
    setup_user
    delete api_solution_iteration_path(999, 999), headers: @headers, as: :json
    assert_response :not_found
    expected = { error: {
      type: "solution_not_found",
      message: I18n.t('api.errors.solution_not_found')
    } }
    assert_equal expected.to_json, response.body
  end

  test "destroy should 404 if the iteration doesn't exist" do
    setup_user
    solution = create :concept_solution, user: @current_user
    delete api_solution_iteration_path(solution.uuid, 999), headers: @headers, as: :json
    assert_response :not_found
    expected = { error: {
      type: "iteration_not_found",
      message: I18n.t('api.errors.iteration_not_found')
    } }
    assert_equal expected.to_json, response.body
  end

  test "destroy should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    iteration = create(:iteration, solution:)
    delete api_solution_iteration_path(solution.uuid, iteration.uuid), headers: @headers, as: :json
    assert_response :forbidden
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "destroy should 404 if the iteration doesn't belong to the solution" do
    setup_user
    solution = create :concept_solution, user: @current_user
    iteration = create :iteration
    delete api_solution_iteration_path(solution.uuid, iteration.uuid), headers: @headers, as: :json
    assert_response :not_found
    expected = { error: {
      type: "iteration_not_found",
      message: I18n.t('api.errors.iteration_not_found')
    } }
    assert_equal expected.to_json, response.body
  end

  test "destroy should soft delete the iteration" do
    setup_user
    solution = create :practice_solution, user: @current_user
    iteration = create(:iteration, solution:)

    Iteration::Destroy.expects(:call).with(iteration)

    delete api_solution_iteration_path(solution.uuid, iteration.uuid), headers: @headers, as: :json
    assert_response :ok
  end

  ###
  # automated_feedback
  ###
  test "automated_feedback should 404 if the solution doesn't exist" do
    setup_user
    get automated_feedback_api_solution_iteration_path(999, 999), headers: @headers, as: :json
    assert_response :not_found
  end

  test "automated_feedback should 404 if the iteration doesn't exist" do
    setup_user
    get automated_feedback_api_solution_iteration_path(create(:concept_solution).uuid, 999), headers: @headers, as: :json
    assert_response :not_found
    expected = { error: {
      type: "iteration_not_found",
      message: I18n.t('api.errors.iteration_not_found')
    } }
    assert_equal expected.to_json, response.body
  end

  test "automated_feedback should 404 if the iteration doesn't belong to the solution" do
    setup_user
    solution = create :concept_solution, user: @current_user
    iteration = create :iteration
    get automated_feedback_api_solution_iteration_path(solution.uuid, iteration.uuid), headers: @headers, as: :json
    assert_response :not_found
    expected = { error: {
      type: "iteration_not_found",
      message: I18n.t('api.errors.iteration_not_found')
    } }
    assert_equal expected.to_json, response.body
  end

  test "automated_feedback should return feedback" do
    setup_user
    solution = create :practice_solution, user: @current_user
    iteration = create(:iteration, solution:)

    get automated_feedback_api_solution_iteration_path(solution.uuid, iteration.uuid), headers: @headers, as: :json

    expected = {
      automated_feedback: {
        representer_feedback: iteration.representer_feedback,
        analyzer_feedback: iteration.analyzer_feedback,
        track: SerializeMentorSessionTrack.(solution.track),
        links: {
          info: Exercism::Routes.doc_path('using', 'feedback/automated')
        }
      }
    }
    assert_response :ok
    assert_equal expected.to_json, response.body
  end
end
