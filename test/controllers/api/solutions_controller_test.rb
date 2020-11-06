require_relative './base_test_case'

class API::SolutionsControllerTest < API::BaseTestCase
  ###
  # LATEST
  ###
  test "latest should return 401 with incorrect token" do
    get latest_api_solutions_path, as: :json
    assert_response 401
    expected = { error: {
      type: "invalid_auth_token",
      message: I18n.t('api.errors.invalid_auth_token')
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
      message: I18n.t('api.errors.track_not_found'),
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
      message: I18n.t('api.errors.exercise_not_found'),
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
      message: I18n.t('api.errors.track_not_joined')
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

    UserTrack.any_instance.expects(:exercise_available?).returns(false)

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
    setup_user
    exercise = create :concept_exercise
    create :concept_solution, user: @current_user, exercise: exercise
    create :user_track, user: @current_user, track: exercise.track

    get latest_api_solutions_path(track_id: exercise.track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response :success
  end

  test "latest should return 200 if solution is unlockable" do
    setup_user
    exercise = create :concept_exercise
    create :user_track, user: @current_user, track: exercise.track

    UserTrack.any_instance.stubs(exercise_available?: true)

    get latest_api_solutions_path(track_id: exercise.track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response :success
  end

  test "latest should use solution serializer" do
    setup_user
    exercise = create :concept_exercise
    track = exercise.track
    create :user_track, user: @current_user, track: track
    solution = create :concept_solution, user: @current_user, exercise: exercise

    get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json

    assert_response :success
    serializer = SerializeSolution.(solution, @current_user)
    assert_equal serializer.to_json, response.body
  end

  test "latest should set downloaded_at" do
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

  test "latest updates git sha if exercise was not previously downloaded" do
    setup_user
    solution = create :concept_solution,
      user: @current_user,
      downloaded_at: nil

    create :user_track, user: @current_user, track: solution.track

    Solution.any_instance.expects(:update_git_info!)
    get latest_api_solutions_path(track_id: solution.track.slug, exercise_id: solution.exercise.slug),
      headers: @headers, as: :json
  end

  test "latest does not update git sha if exercise was downloaded" do
    setup_user
    solution = create :concept_solution,
      user: @current_user,
      downloaded_at: Time.current

    create :user_track, user: @current_user, track: solution.track

    Solution.any_instance.expects(:update_git_info!).never
    get latest_api_solutions_path(track_id: solution.track.slug, exercise_id: solution.exercise.slug),
      headers: @headers, as: :json
  end

  ###
  # SHOW
  ###
  test "show should return 401 with incorrect token" do
    get api_solution_path(1), as: :json
    assert_response 401
    expected = { error: {
      type: "invalid_auth_token",
      message: I18n.t('api.errors.invalid_auth_token')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ### Errors: User is not the author
  test "show should return 404 if user is not author" do
    setup_user
    solution = create :concept_solution
    create :user_track, user: @current_user, track: solution.track

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
    setup_user
    solution = create :concept_solution, user: @current_user
    create :user_track, user: solution.user, track: solution.track

    get api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :success
    serializer = SerializeSolution.(solution, @current_user)
    assert_equal serializer.to_json, response.body
  end

  test "show should set downloaded_at" do
    freeze_time do
      setup_user
      exercise = create :concept_exercise
      track = exercise.track
      solution = create :concept_solution, user: @current_user, exercise: exercise
      create :user_track, user: solution.user, track: track

      get api_solution_path(solution.uuid), headers: @headers, as: :json
      assert_response :success

      solution.reload
      assert_equal solution.downloaded_at.to_i, DateTime.now.to_i
    end
  end

  test "show updates git sha if exercise was not previously downloaded" do
    setup_user
    solution = create :concept_solution,
      user: @current_user,
      downloaded_at: nil

    create :user_track, user: @current_user, track: solution.track

    Solution.any_instance.expects(:update_git_info!)
    get api_solution_path(solution.uuid), headers: @headers, as: :json
  end

  test "show does not update git sha if exercise was downloaded" do
    setup_user
    solution = create :concept_solution,
      user: @current_user,
      downloaded_at: Time.current

    create :user_track, user: @current_user, track: solution.track

    Solution.any_instance.expects(:update_git_info!).never
    get api_solution_path(solution.uuid), headers: @headers, as: :json
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
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "update should create submission and iteration" do
    setup_user
    exercise = create :concept_exercise
    solution = create :concept_solution, user: @current_user, exercise: exercise

    created_submission = create(:submission)

    http_files = [SecureRandom.uuid, SecureRandom.uuid]
    files = mock
    Submission::PrepareHttpFiles.expects(:call).with(http_files).returns(files)
    Submission::Create.expects(:call).with(solution, files, :cli).returns(created_submission)
    Iteration::Create.expects(:call).with(solution, created_submission)

    patch api_solution_path(solution.uuid),
      params: { files: http_files },
      headers: @headers,
      as: :json

    assert_response :success
  end

  test "update should catch duplicate submission" do
    setup_user
    solution = create :concept_solution, user: @current_user

    Submission::Create.expects(:call).raises(DuplicateSubmissionError)

    patch api_solution_path(solution.uuid),
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
