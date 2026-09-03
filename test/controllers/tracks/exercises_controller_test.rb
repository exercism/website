require "test_helper"

class Tracks::ExercisesControllerTest < ActionDispatch::IntegrationTest
  test "index: renders correctly for external" do
    track = create :track

    get track_exercises_url(track)
    assert_template "tracks/exercises/index"
  end

  test "index: renders correctly for joined" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)

    sign_in!(user)

    get track_exercises_url(track)
    assert_template "tracks/exercises/index"
  end

  test "index: renders correctly for unjoined" do
    user = create :user
    track = create :track

    sign_in!(user)

    get track_exercises_url(track)
    assert_template "tracks/exercises/index"
  end

  test "index: renders correctly for inactive track and user is a maintainer" do
    user = create :user, roles: [:maintainer]
    track = create :track, active: false

    sign_in!(user)

    get track_exercises_url(track)

    assert_template "tracks/exercises/index"
  end

  test "index: 404s silently for inactive track and user is not a maintainer" do
    user = create :user
    track = create :track, active: false

    sign_in!(user)

    get track_exercises_url(track)

    assert_rendered_404
  end

  test "show: 404s silently for missing track" do
    get track_exercise_url('foobar', 'foobar')

    assert_rendered_404
  end

  test "show: 404s silently for missing exercise" do
    get track_exercise_url(create(:track), 'foobar')

    assert_rendered_404
  end

  test "show: 404s silently for inactive track and user is not a maintainer" do
    user = create :user
    track = create :track, active: false
    exercise = create(:practice_exercise, track:)

    sign_in!(user)

    get track_exercise_url(exercise.track, exercise)

    assert_rendered_404
  end

  test "show: renders correctly for inactive track and user is a maintainer" do
    user = create :user, roles: [:maintainer]
    track = create :track, active: false
    exercise = create(:practice_exercise, track:)

    sign_in!(user)

    get track_exercise_url(exercise.track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "concept/show: renders correctly for external" do
    exercise = create :concept_exercise

    get track_exercise_url(exercise.track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "concept/show: renders correctly for joined" do
    user = create :user
    exercise = create :concept_exercise
    create :user_track, user:, track: exercise.track

    sign_in!(user)

    get track_exercise_url(exercise.track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "concept/show: renders correctly for unjoined" do
    user = create :user
    exercise = create :concept_exercise

    sign_in!(user)

    get track_exercise_url(exercise.track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "practice/show: renders correctly for external" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "practice/show: renders correctly for joined" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)

    sign_in!(user)

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "practice/show: renders correctly for unjoined" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:)

    sign_in!(user)

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "edit: is fine if there's a solution" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track:, slug: "hello-world"

    create(:user_track, user:, track:)
    create(:practice_solution, user:, exercise:)

    sign_in!(user)

    get edit_track_exercise_url(track, exercise)
    assert_template "tracks/exercises/edit"
  end

  test "edit: is cross-origin isolated" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:, slug: "hello-world")

    create(:user_track, user:, track:)
    create(:practice_solution, user:, exercise:)

    sign_in!(user)

    get edit_track_exercise_url(track, exercise)

    # SharedArrayBuffer needs both of these. See CrossOriginIsolation.
    assert_equal "same-origin", response.headers["Cross-Origin-Opener-Policy"]
    assert_equal "credentialless", response.headers["Cross-Origin-Embedder-Policy"]
  end

  test "edit: tells turbo to do a full page load" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:, slug: "hello-world")

    create(:user_track, user:, track:)
    create(:practice_solution, user:, exercise:)

    sign_in!(user)

    # Cross-origin isolation is a property of the document, so the editor is
    # only isolated when the browser really navigates to it. Rendering into the
    # turbo frame would silently lose it, so a frame request must still get a
    # full document carrying the turbo-visit-control meta tag.
    get edit_track_exercise_url(track, exercise), headers: { "Turbo-Frame" => "tf-main" }

    assert_response :success

    # A full document, not the bare turbo_frame layout...
    assert_select "head"
    # ...carrying the tag that makes Turbo hand over to a real page load.
    assert_select "meta[name=?][content=?]", "turbo-visit-control", "reload"
  end

  test "show: still renders into the turbo frame" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)

    sign_in!(user)

    get track_exercise_url(track, exercise), headers: { "Turbo-Frame" => "tf-main" }

    assert_response :success
    assert_select "turbo-frame#tf-main"
    assert_select "head", count: 0
  end

  test "edit: creates a solution if one is missing" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track:, slug: "hello-world"

    create(:user_track, user:, track:)

    sign_in!(user)

    get edit_track_exercise_url(track, exercise)
    assert_template "tracks/exercises/edit"
    assert PracticeSolution.find_by(user:, exercise:)
  end

  test "edit: redirects if exercise is locked" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track:, slug: "hello-world"
    UserTrack.any_instance.expects(:exercise_unlocked?).with(exercise).returns(false)

    create(:user_track, user:, track:)

    sign_in!(user)

    get edit_track_exercise_url(track, exercise)
    assert_redirected_to action: :show
  end

  test "edit: redirects if track not joined" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track:, slug: "hello-world"

    sign_in!(user)

    get edit_track_exercise_url(track, exercise)
    assert_redirected_to action: :show
  end

  test "edit: redirects if there is no test runner" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create :practice_exercise, has_test_runner: false

    sign_in!(user)

    get edit_track_exercise_url(track, exercise)
    assert_redirected_to action: :no_test_runner
  end

  test "no_test_runner renders if there is no test runner" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create :practice_exercise, has_test_runner: false

    sign_in!(user)

    get no_test_runner_track_exercise_url(track, exercise)
    assert_response :ok
  end

  test "no_test_runner redirects if there is a test runner" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create :practice_exercise, has_test_runner: true

    sign_in!(user)

    get no_test_runner_track_exercise_url(track, exercise)
    assert_redirected_to action: :edit
  end
end
