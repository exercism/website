require_relative './base_test_case'

class API::SolutionsControllerTest < API::BaseTestCase
  def setup
    # mock_exercise mock_exercise
    # @mock_repo = stub(exercise: @mock_exercise,
    #                  ignore_regexp: /somethingtoignore/,
    #                  head: "4567")
    # Git::ExercismRepo.stubs(new: @mock_repo)
  end

  ###
  # LATEST
  ###
  test "latest should return 401 with incorrect token" do
    get latest_api_solutions_path, as: :json
    assert_response 401
    expected = { error: {
      type: "invalid_auth_token",
      message: "The auth token provided is invalid"
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ### Errors: Track Not Found
  test "latest should return 404 when the track doesn't exist" do
    setup_user
    exercise = create :concept_exercise
    get latest_api_solutions_path(exercise_id: exercise.slug, track_id: SecureRandom.uuid), headers: @headers, as: :json
    assert_response 404
    expected = { error: {
      type: "track_not_found",
      message: "The track you specified does not exist",
      fallback_url: tracks_url
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ### Errors: Exercise Not Found
  test "latest should return 404 when there is no exercise" do
    setup_user
    track = create :track
    get latest_api_solutions_path(track_id: track.slug), headers: @headers, as: :json
    assert_response 404
    expected = { error: {
      type: "exercise_not_found",
      message: "The exercise you specified could not be found",
      fallback_url: track_url(track)
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ### Errors: Track Not Joined
  test "latest should return 403 when the track isn't joined" do
    setup_user
    track = create :track
    exercise = create :concept_exercise, track: track
    get latest_api_solutions_path(exercise_id: exercise.slug, track_id: track.slug), headers: @headers, as: :json
    assert_response 403
    expected = { error: {
      type: "track_not_joined",
      message: "You have not joined this track"
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ### Errors: Solution Not Unlocked
  test "latest should return 403 when solution cannot be unlocked" do
    setup_user
    track = create :track
    create :user_track, user: @current_user, track: track
    exercise = create :concept_exercise, track: track

    UserTrack.any_instance.expects(:exercise_available?).with(exercise).returns(false)

    get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "solution_not_unlocked",
      message: I18n.t('api.errors.solution_not_unlocked')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "latest should return 200 if solution is unlocked" do
    skip
    setup_user
    track = create :track
    core = create :concept_exercise, track: track
    exercise = create :concept_exercise, unlocked_by: core, track: track
    create :concept_solution, user: @current_user, exercise: exercise
    create :user_track, user: @current_user, track: track

    get latest_api_solutions_path(exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response :success
  end

  test "latest should return 200 if solution is unlockable" do
    skip
    setup_user
    track = create :track
    core = create :concept_exercise, track: track
    exercise = create :concept_exercise, unlocked_by: core, track: track
    create :user_track, user: @current_user, track: track

    UserTrack.any_instance.expects(:exercise_available?).with(exercise).returns(true)

    get latest_api_solutions_path(exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response :success
  end

  test "latest should use solution serializer" do
    skip
    setup_user
    exercise = create :concept_exercise
    track = exercise.track
    create :user_track, user: @current_user, track: track
    create :concept_solution, user: @current_user, exercise: exercise

    expected = { foo: 'bar' }
    serializer = mock(to_hash: expected)
    API::SolutionSerializer.expects(:new).returns(serializer)

    get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json

    assert_response :success
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "latest should set downloaded_at" do
    skip
    freeze_time do
      setup_user
      exercise = create :concept_exercise
      track = exercise.track
      solution = create :concept_solution, user: @current_user, exercise: exercise
      create :user_track, user: solution.user, track: track

      get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
      assert_response :success

      solution.reload
      assert_equal solution.downloaded_at.to_i, DateTime.now.to_i
    end
  end

  test "latest should update git slug and sha if exercise is downloaded for the first time" do
    skip
    freeze_time do
      setup_user
      exercise = create :concept_exercise
      track = exercise.track
      solution = create :concept_solution,
                        user: @current_user,
                        exercise: exercise,
                        downloaded_at: nil,
                        git_sha: "1234",
                        git_slug: 'meh'
      create :user_track, user: solution.user, track: track

      get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json

      solution.reload
      assert_equal exercise.slug, solution.git_slug
      assert_equal "4567", solution.git_sha
    end
  end

  test "latest does not update git sha if exercise was downloaded" do
    skip
    freeze_time do
      setup_user
      exercise = create :concept_exercise
      track = exercise.track
      solution = create :concept_solution,
                        user: @current_user,
                        exercise: exercise,
                        downloaded_at: Time.utc(2016, 12, 25),
                        git_sha: "1234"
      create :user_track, user: solution.user, track: track

      get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json

      solution.reload
      assert_equal "1234", solution.git_sha
    end
  end

  ###
  # SHOW
  ###
  test "show should return 401 with incorrect token" do
    get api_solution_path(1), as: :json
    assert_response 401
    expected = { error: {
      type: "invalid_auth_token",
      message: "The auth token provided is invalid"
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ### Errors: User is not the author
  test "show should return 404 if user is not author" do
    setup_user
    solution = create :concept_solution

    get api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response 404
    expected = { error: {
      type: "solution_not_found",
      message: I18n.t('api.errors.solution_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "show should use solution serializer" do
    skip
    setup_user
    solution = create :concept_solution, user: @current_user

    expected = { foo: 'bar' }
    serializer = mock(to_hash: expected)
    API::SolutionSerializer.expects(:new).returns(serializer)

    get api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :success
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "show should set downloaded_at" do
    skip
    freeze_time do
      setup_user
      solution = create :concept_solution, user: @current_user

      get api_solution_path(solution.uuid), headers: @headers, as: :json
      assert_response :success

      solution.reload
      assert_equal solution.downloaded_at.to_i, DateTime.now.to_i
    end
  end

  test "show should update git slug and sha if exercise is downloaded for the first time" do
    skip
    freeze_time do
      setup_user
      solution = create :concept_solution,
                        user: @current_user,
                        downloaded_at: nil,
                        git_sha: "1234",
                        git_slug: 'meh'

      get api_solution_path(solution.uuid), headers: @headers, as: :json

      solution.reload
      assert_equal exercise.slug, solution.git_slug
      assert_equal "4567", solution.git_sha
    end
  end

  test "show does not update git sha if exercise was downloaded" do
    skip
    freeze_time do
      setup_user
      solution = create :concept_solution,
                        user: @current_user,
                        downloaded_at: Time.utc(2016, 12, 25),
                        git_sha: "1234"

      get api_solution_path(solution.uuid), headers: @headers, as: :json

      solution.reload
      assert_equal "1234", solution.git_sha
    end
  end

  ###
  # UPDATE
  ###
  test "update should return 401 with incorrect token" do
    patch api_solution_path(1), headers: @headers, as: :json
    assert_response 401
  end

  test "update should 404 if the solution doesn't exist" do
    setup_user
    patch api_solution_path(999), headers: @headers, as: :json
    assert_response 404
  end

  test "update should 404 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    patch api_solution_path(solution.uuid), headers: @headers, as: :json
    assert_response 403
    expected = { error: {
      type: "solution_not_accessible",
      message: "You do not have permission to view this solution"
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "update should create iteration" do
    setup_user
    exercise = create :concept_exercise
    solution = create :concept_solution, user: @current_user, exercise: exercise

    http_files = [SecureRandom.uuid, SecureRandom.uuid]
    files = mock
    CLI::PrepareUploadedFiles.expects(:call).with(http_files).returns(files)
    Iteration::Create.expects(:call).with(solution, files, :cli)

    patch api_solution_path(solution.uuid),
          params: { files: http_files },
          headers: @headers,
          as: :json

    assert_response :success
  end

  test "update should catch duplicate iteration" do
    setup_user
    exercise = create :concept_exercise
    solution = create :concept_solution, user: @current_user, exercise: exercise

    Iteration::Create.expects(:call).raises(DuplicateIterationError)

    patch api_solution_path(solution.uuid),
          params: { files: [] },
          headers: @headers,
          as: :json

    assert_response 400
    expected = { error: {
      type: "duplicate_iteration",
      message: "No files you submitted have changed since your last iteration"
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
end
