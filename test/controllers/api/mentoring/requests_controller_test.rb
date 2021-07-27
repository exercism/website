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

    params = {
      page: 15,
      criteria: "Ruby",
      order: "recent",
      track_slug: 'ruby',
      exercise_slug: 'bob'
    }
    expected = { 'foo' => 'bar' }

    AssembleMentorRequests.expects(:call).returns(expected).with do |actual_user, actual_params|
      assert_equal user, actual_user
      assert params, actual_params
    end

    get api_mentoring_requests_path, params: params, headers: @headers, as: :json
  end

  test "index retrieves requests" do
    user = create :user
    setup_user(user)

    mentored_track = create :track
    create :user_track_mentorship, user: user, track: mentored_track
    solution = create :concept_solution, track: mentored_track
    50.times { create :mentor_request, solution: solution }

    get api_mentoring_requests_path, headers: @headers, as: :json
    assert_response 200
    assert_includes AssembleMentorRequests.(user, {}).to_json, response.body
  end

  test "index updates last_viewed" do
    user = create :user
    setup_user(user)

    ruby = create :track, slug: :ruby
    js = create :track, slug: :js
    ruby_mentorship = create :user_track_mentorship, user: user, track: ruby
    js_mentorship = create :user_track_mentorship, user: user, track: js

    refute ruby_mentorship.reload.last_viewed? # Sanity
    refute js_mentorship.reload.last_viewed? # Sanity

    get api_mentoring_requests_path(track_slug: :ruby), headers: @headers, as: :json
    assert_response 200

    assert ruby_mentorship.reload.last_viewed?
    refute js_mentorship.reload.last_viewed?

    get api_mentoring_requests_path(track_slug: :js), headers: @headers, as: :json
    assert_response 200

    refute ruby_mentorship.reload.last_viewed?
    assert js_mentorship.reload.last_viewed?

    # Test invalid slug doesn't override
    get api_mentoring_requests_path(track_slug: :foo), headers: @headers, as: :json
    assert_response 200

    refute ruby_mentorship.reload.last_viewed?
    assert js_mentorship.reload.last_viewed?

    # Test missing slug doesn't override
    get api_mentoring_requests_path, headers: @headers, as: :json
    assert_response 200

    refute ruby_mentorship.reload.last_viewed?
    assert js_mentorship.reload.last_viewed?
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
    solution = create :concept_solution
    request = create :mentor_request, solution: solution
    create :iteration, solution: solution

    patch lock_api_mentoring_request_path(request.uuid), headers: @headers, as: :json

    assert_response :success

    assert request.reload.locked?
    assert_equal user, request.reload.locks.last.locked_by
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
