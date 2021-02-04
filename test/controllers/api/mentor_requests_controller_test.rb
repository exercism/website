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

  test "index proxies correctly" do
    user = create :user
    setup_user(user)
    page = 15
    track_id = 24
    exercise_ids = [17, 19]

    ::Solution::MentorRequest::Retrieve.expects(:call).with(
      @current_user,
      page: page,
      track_slug: track_id,
      exercise_slugs: exercise_ids,
      sorted: false, paginated: false
    ).returns(mock(count: 200))

    Solution::MentorRequest::Retrieve.expects(:call).with(
      @current_user,
      page: page,
      track_slug: track_id,
      exercise_slugs: exercise_ids
    ).returns(Solution::MentorRequest.page(1).per(1))

    get api_mentor_requests_path, params: {
      page: page,
      track_id: track_id,
      exercise_ids: exercise_ids
    }, headers: @headers, as: :json
  end

  test "index retrieves requests" do
    user = create :user
    setup_user(user)

    mentored_track = create :track
    solution = create :concept_solution, track: mentored_track
    request = create :solution_mentor_request, created_at: Time.current - 2.minutes, solution: solution
    50.times { create :solution_mentor_request, solution: solution }

    get api_mentor_requests_path, headers: @headers, as: :json
    assert_response 200

    # TODO: Check JSON
    assert_equal 51, JSON.parse(response.body)['meta']['unscoped_total']
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

  ###
  # Tracks
  ###
  test "tracks proxies correctly" do
    user = create :user
    setup_user(user)
    output = { 'foo' => 'bar' }

    ::Solution::MentorRequest::RetrieveTracks.expects(:call).with(@current_user).returns(output)

    get tracks_api_mentor_requests_path, headers: @headers, as: :json
    assert_equal output, JSON.parse(response.body)
  end

  ###
  # Exercises
  ###
  test "exercises proxies correctly" do
    user = create :user
    setup_user(user)
    slug = 'ruby'
    output = { 'foo' => 'bar' }

    ::Solution::MentorRequest::RetrieveExercises.expects(:call).with(@current_user, slug).returns(output)

    get exercises_api_mentor_requests_path, params: { track_id: slug }, headers: @headers, as: :json
    assert_equal output, JSON.parse(response.body)
  end
end
