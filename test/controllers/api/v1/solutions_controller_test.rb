require_relative '../base_test_case'

class API::V1::SolutionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :latest_api_v1_solutions_path
  guard_incorrect_token! :api_v1_solution_path, args: 1
  guard_incorrect_token! :api_v1_solution_path, args: 1, method: :patch

  ###
  # LATEST
  ###

  ### Errors: Track Not Found
  test "latest should return 404 when the track doesn't exist" do
    setup_user
    exercise = create :concept_exercise
    get latest_api_v1_solutions_path(exercise_id: exercise.slug, track_id: SecureRandom.uuid), headers: @headers, as: :json
    assert_response :not_found
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
    get latest_api_v1_solutions_path(track_id: track.slug), headers: @headers, as: :json
    assert_response :not_found
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
    exercise = create(:concept_exercise, track:)
    get latest_api_v1_solutions_path(exercise_id: exercise.slug, track_id: track.slug), headers: @headers, as: :json
    assert_response :forbidden
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
    create(:user_track, user: @current_user, track:)
    exercise = create(:concept_exercise, track:)

    UserTrack.any_instance.expects(:exercise_unlocked?).returns(false)

    get latest_api_v1_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json

    assert_response :forbidden
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
    create(:concept_solution, user: @current_user, exercise:)
    create :user_track, user: @current_user, track: exercise.track

    get latest_api_v1_solutions_path(track_id: exercise.track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response :ok
  end

  test "latest should return 200 if solution is unlockable" do
    setup_user
    exercise = create :concept_exercise
    create :user_track, user: @current_user, track: exercise.track

    UserTrack.any_instance.stubs(exercise_unlocked?: true)

    get latest_api_v1_solutions_path(track_id: exercise.track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response :ok
  end

  test "latest should use solution serializer" do
    setup_user
    exercise = create :concept_exercise
    track = exercise.track
    create(:user_track, user: @current_user, track:)
    solution = create(:concept_solution, user: @current_user, exercise:)

    get latest_api_v1_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json

    assert_response :ok
    serializer = SerializeSolutionForCLI.(solution, @current_user)
    assert_equal serializer.to_json, response.body
  end

  test "latest should set downloaded_at" do
    freeze_time do
      setup_user
      exercise = create :concept_exercise
      track = exercise.track
      solution = create(:concept_solution, user: @current_user, exercise:)
      create(:user_track, user: solution.user, track:)

      get latest_api_v1_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
      assert_response :ok

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

    Solution::UpdateToLatestExerciseVersion.expects(:call).with(solution)

    get latest_api_v1_solutions_path(track_id: solution.track.slug, exercise_id: solution.exercise.slug),
      headers: @headers, as: :json
  end

  test "latest does not update git sha if exercise was downloaded" do
    setup_user
    solution = create :concept_solution,
      user: @current_user,
      downloaded_at: Time.current

    create :user_track, user: @current_user, track: solution.track

    Solution::UpdateToLatestExerciseVersion.expects(:call).never

    get latest_api_v1_solutions_path(track_id: solution.track.slug, exercise_id: solution.exercise.slug),
      headers: @headers, as: :json
  end

  ###
  # SHOW
  ###

  ### Errors: User is not the author
  test "show should return 403 if user is not allowed" do
    user = create :user
    solution = create :concept_solution
    ConceptSolution.any_instance.expects(:viewable_by?).with(user).returns(false)

    setup_user(user)
    get api_v1_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "show should return 200 if user is allowed" do
    solution = create :concept_solution

    setup_user(solution.user)
    get api_v1_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :ok
  end

  test "show should use solution serializer" do
    setup_user
    solution = create :concept_solution, user: @current_user
    create :user_track, user: solution.user, track: solution.track

    get api_v1_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :ok
    serializer = SerializeSolutionForCLI.(solution, @current_user)
    assert_equal serializer.to_json, response.body
  end

  test "show should set downloaded_at for solution user" do
    freeze_time do
      setup_user
      solution = create :concept_solution, user: @current_user
      create :user_track, user: solution.user, track: solution.track

      get api_v1_solution_path(solution.uuid), headers: @headers, as: :json
      assert_response :ok

      assert_equal solution.reload.downloaded_at.to_i, DateTime.now.to_i
    end
  end

  test "show should not set downloaded_at for other user" do
    freeze_time do
      user = create :user
      solution = create :concept_solution, published_at: Time.current

      setup_user(user)
      get api_v1_solution_path(solution.uuid), headers: @headers, as: :json
      assert_response :ok

      assert_nil solution.reload.downloaded_at
    end
  end

  test "show updates git sha if exercise was not previously downloaded" do
    setup_user
    solution = create :concept_solution, user: @current_user

    create :user_track, user: @current_user, track: solution.track

    Solution::UpdateToLatestExerciseVersion.expects(:call).with(solution)

    get api_v1_solution_path(solution.uuid), headers: @headers, as: :json
  end

  test "show does not update git sha if exercise was downloaded" do
    setup_user
    solution = create :concept_solution, user: @current_user, downloaded_at: Time.current

    create :user_track, user: @current_user, track: solution.track

    Solution::UpdateToLatestExerciseVersion.expects(:call).never

    get api_v1_solution_path(solution.uuid), headers: @headers, as: :json
  end

  ###
  # UPDATE
  ###
  test "update should 404 if the solution doesn't exist" do
    setup_user
    patch api_v1_solution_path(999), headers: @headers, as: :json
    assert_response :not_found
  end

  test "update should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    patch api_v1_solution_path(solution.uuid), headers: @headers, as: :json
    assert_response :forbidden
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
    solution = create(:concept_solution, user: @current_user, exercise:)

    created_submission = create(:submission, solution:)

    http_files = [SecureRandom.uuid, SecureRandom.uuid]
    files = mock
    Submission::PrepareHttpFiles.expects(:call).with(http_files).returns(files)
    Submission::Create.expects(:call).with(solution, files, :cli).returns(created_submission)
    Iteration::Create.expects(:call).with(solution, created_submission)

    patch api_v1_solution_path(solution.uuid),
      params: { files: http_files },
      headers: @headers,
      as: :json

    assert_response :created
  end

  test "update should init test run" do
    setup_user
    exercise = create :concept_exercise
    solution = create(:concept_solution, user: @current_user, exercise:)

    http_files = [SecureRandom.uuid, SecureRandom.uuid]
    files = []
    Submission::PrepareHttpFiles.expects(:call).with(http_files).returns(files)

    # Ensure representer and analyzer are called once
    ToolingJob::Create.expects(:call).with(anything, :representer, git_sha: "HEAD", run_in_background: false, context: {})
    ToolingJob::Create.expects(:call).with(anything, :analyzer, run_in_background: false)

    # Ensure test runner is called once, in the foreground, and not again in the background
    ToolingJob::Create.expects(:call).with(anything, :test_runner, git_sha: "HEAD", run_in_background: false)

    patch api_v1_solution_path(solution.uuid),
      params: { files: http_files },
      headers: @headers,
      as: :json

    assert_response :created

    # Run the jobs through to make sure nothing unexpected happens
    perform_enqueued_jobs
  end
  test "update should catch duplicate submission" do
    setup_user
    solution = create :concept_solution, user: @current_user

    Submission::Create.expects(:call).raises(DuplicateSubmissionError)

    patch api_v1_solution_path(solution.uuid),
      params: { files: [] },
      headers: @headers,
      as: :json

    assert_response :bad_request
    expected = { error: {
      type: "duplicate_submission",
      message: I18n.t('api.errors.duplicate_submission')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
end
