require "test_helper"

class Tracks::ApproachesControllerTest < ActionDispatch::IntegrationTest
  test "index: 404s when track does not exist" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track

    sign_in!(user)

    get track_exercise_approaches_url('unknown', exercise)

    assert_rendered_404
  end

  test "index: 404s when exercise does not exist" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track

    sign_in!(user)

    get track_exercise_approaches_url(track, 'unknown')

    assert_rendered_404
  end

  test "index: renders correctly for external" do
    track = create :track
    exercise = create :practice_exercise, track: track

    get track_exercise_approaches_url(track, exercise)

    assert_template "tracks/approaches/index"
  end

  test "index: redirects when exercise is hello-world" do
    track = create :track
    exercise = create :hello_world_exercise, track: track

    get track_exercise_approaches_url(track, exercise)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "index: redirects when not iterated and not unlocked help" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    create :concept_solution, user: user, exercise: exercise

    sign_in!(user)

    get track_exercise_approaches_url(track, exercise)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "index: renders when not iterated but unlocked help" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    create :concept_solution, user: user, exercise: exercise, unlocked_help: true

    sign_in!(user)

    get track_exercise_approaches_url(track, exercise)

    assert_template "tracks/approaches/index"
  end

  test "index: renders when iterated" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    solution = create :concept_solution, user: user, exercise: exercise, unlocked_help: true
    create :iteration, solution: solution, user: user

    sign_in!(user)

    get track_exercise_approaches_url(track, exercise)

    assert_template "tracks/approaches/index"
  end

  test "show: renders correctly for external" do
    track = create :track
    exercise = create :practice_exercise, track: track
    approach = create :exercise_approach, exercise: exercise

    get track_exercise_approach_url(track, exercise, approach)

    assert_template "tracks/approaches/show"
  end

  test "show: redirects when exercise is hello-world" do
    track = create :track
    exercise = create :hello_world_exercise, track: track
    approach = create :exercise_approach, exercise: exercise

    get track_exercise_approach_url(track, exercise, approach)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "show: redirects when not iterated and not unlocked help" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    approach = create :exercise_approach, exercise: exercise
    create :concept_solution, user: user, exercise: exercise

    sign_in!(user)

    get track_exercise_approach_url(track, exercise, approach)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "show: 404s when track does not exist" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    approach = create :exercise_approach, exercise: exercise

    sign_in!(user)

    get track_exercise_approach_url('unknown', exercise, approach)

    assert_rendered_404
  end

  test "show: 404s when exercise does not exist" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    approach = create :exercise_approach, exercise: exercise

    sign_in!(user)

    get track_exercise_approach_url(track, 'unknown', approach)

    assert_rendered_404
  end

  test "show: 404s when approach does not exist" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track

    sign_in!(user)

    get track_exercise_approach_url(track, exercise, 'unknown')

    assert_rendered_404
  end

  test "show: renders when not iterated but unlocked help" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    approach = create :exercise_approach, exercise: exercise
    create :concept_solution, user: user, exercise: exercise, unlocked_help: true

    sign_in!(user)

    get track_exercise_approach_url(track, exercise, approach)

    assert_template "tracks/approaches/show"
  end

  test "show: renders when iterated" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    approach = create :exercise_approach, exercise: exercise
    solution = create :concept_solution, user: user, exercise: exercise, unlocked_help: true
    create :iteration, solution: solution, user: user

    sign_in!(user)

    get track_exercise_approach_url(track, exercise, approach)

    assert_template "tracks/approaches/show"
  end

  test "tooltip_locked: renders when external" do
    track = create :track
    exercise = create :practice_exercise, track: track

    get tooltip_locked_track_exercise_approaches_url(track, exercise)

    assert_response :ok
  end

  test "tooltip_locked: renders when not iterated and not unlocked help" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    create :concept_solution, user: user, exercise: exercise

    sign_in!(user)

    get tooltip_locked_track_exercise_approaches_url(track, exercise)

    assert_template "tracks/approaches/tooltip_locked"
  end

  test "tooltip_locked: 404s when track does not exist" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track

    sign_in!(user)

    get tooltip_locked_track_exercise_approaches_url('unknown', exercise)

    assert_rendered_404
  end

  test "tooltip_locked: 404s when exercise does not exist" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track

    sign_in!(user)

    get tooltip_locked_track_exercise_approaches_url(track, 'unknown')

    assert_rendered_404
  end

  test "tooltip_locked: renders when not iterated but unlocked help" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    create :concept_solution, user: user, exercise: exercise, unlocked_help: true

    sign_in!(user)

    get tooltip_locked_track_exercise_approaches_url(track, exercise)

    assert_template "tracks/approaches/tooltip_locked"
  end

  test "tooltip_locked: renders when iterated" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    solution = create :concept_solution, user: user, exercise: exercise, unlocked_help: true
    create :iteration, solution: solution, user: user

    sign_in!(user)

    get tooltip_locked_track_exercise_approaches_url(track, exercise)

    assert_template "tracks/approaches/tooltip_locked"
  end
end
