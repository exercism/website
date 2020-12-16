require_relative './base_test_case'

class API::MentorRequestsControllerTest < API::BaseTestCase
  ###
  # Index
  ###
  test "index should return 401 with incorrect token" do
    get api_mentor_requests_path, as: :json

    assert_response 401
    expected = { error: {
      type: "invalid_auth_token",
      message: I18n.t('api.errors.invalid_auth_token')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "index retrieves requests" do
    user = create :user
    setup_user(user)

    mentored_track = create :track
    solution = create :concept_solution, track: mentored_track
    request = create :solution_mentor_request, created_at: Time.current - 2.minutes, solution: solution

    get api_mentor_requests_path, headers: @headers, as: :json
    assert_response 200

    # TODO: Check JSON
    assert_includes response.body, request.uuid
  end

  ###
  # Lock
  ###
  test "lock should return 401 with incorrect token" do
    patch lock_api_mentor_request_path('xxx'), headers: @headers, as: :json
    assert_response 401
  end

  test "lock should 404 if the request doesn't exist" do
    setup_user
    patch lock_api_mentor_request_path('xxx'), headers: @headers, as: :json
    assert_response 404
  end

  test "locks should succeed" do
    user = create :user
    setup_user(user)
    request = create :solution_mentor_request

    patch lock_api_mentor_request_path(request.uuid), headers: @headers, as: :json

    assert_response :success

    assert request.reload.locked?
    assert_equal user, request.reload.locked_by
  end
end
