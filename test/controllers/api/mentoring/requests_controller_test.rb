require_relative '../base_test_case'

class API::Mentoring::RequestsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_mentoring_requests_path
  guard_incorrect_token! :lock_api_mentoring_request_path, args: 1, method: :patch

  ###
  # Index
  ###
  test "index proxies correctly" do
    user = create :user
    setup_user(user)
    page = 15
    track_slug = "ruby"
    exercise_slug = "bob"

    ::Mentor::Request::Retrieve.expects(:call).with(
      mentor: user,
      page: page,
      track_slug: track_slug,
      exercise_slug: exercise_slug,
      sorted: false,
      paginated: false
    ).returns(mock(count: 200))

    Mentor::Request::Retrieve.expects(:call).with(
      mentor: user,
      page: page,
      criteria: "Ruby",
      order: "recent",
      track_slug: track_slug,
      exercise_slug: exercise_slug
    ).returns(Mentor::Request.page(1).per(1))

    get api_mentoring_requests_path, params: {
      page: page,
      criteria: "Ruby",
      order: "recent",
      track_slug: track_slug,
      exercise_slug: exercise_slug
    }, headers: @headers, as: :json
  end

  test "index retrieves requests" do
    user = create :user
    setup_user(user)

    mentored_track = create :track
    create :user_track_mentorship, user: user, track: mentored_track
    solution = create :concept_solution, track: mentored_track
    request = create :mentor_request, created_at: Time.current - 2.minutes, solution: solution
    50.times { create :mentor_request, solution: solution }

    get api_mentoring_requests_path, headers: @headers, as: :json
    assert_response 200

    # TODO: Check JSON
    assert_equal 51, JSON.parse(response.body)['meta']['unscoped_total']
    assert_includes response.body, request.uuid
  end

  ###
  # Lock
  ###
  test "lock should 404 if the request doesn't exist" do
    setup_user
    patch lock_api_mentoring_request_path('xxx'), headers: @headers, as: :json
    assert_response 404
  end

  test "locks should succeed" do
    user = create :user
    setup_user(user)
    request = create :mentor_request

    patch lock_api_mentoring_request_path(request.uuid), headers: @headers, as: :json

    assert_response :success

    assert request.reload.locked?
    assert_equal user, request.reload.locked_by
  end

  ###
  # Exercises
  ###
  test "exercises proxies correctly" do
    user = create :user
    setup_user(user)
    slug = 'ruby'
    output = { 'foo' => 'bar' }

    ::Mentor::Request::RetrieveExercises.expects(:call).with(@current_user, slug).returns(output)

    get exercises_api_mentoring_requests_path, params: { track_slug: slug }, headers: @headers, as: :json
    assert_equal output, JSON.parse(response.body)
  end
end
