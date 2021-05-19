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
    create :user_track, user: user, track: track

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

  test "concept/show: renders correctly for external" do
    exercise = create :concept_exercise

    get track_exercise_url(exercise.track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "concept/show: renders correctly for joined" do
    user = create :user
    exercise = create :concept_exercise
    create :user_track, user: user, track: exercise.track

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
    exercise = create :practice_exercise, track: track

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "practice/show: renders correctly for joined" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track

    sign_in!(user)

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "practice/show: renders correctly for unjoined" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track: track

    sign_in!(user)

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "edit: is fine if there's a solution" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track: track, slug: "hello-world"

    create :user_track, user: user, track: track
    create :practice_solution, user: user, exercise: exercise

    sign_in!(user)

    get edit_track_exercise_url(track, exercise)
    assert_template "tracks/exercises/edit"
  end

  test "edit: creates a solution if one is missing" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track: track, slug: "hello-world"

    create :user_track, user: user, track: track

    sign_in!(user)

    get edit_track_exercise_url(track, exercise)
    assert_template "tracks/exercises/edit"
    assert PracticeSolution.find_by(user: user, exercise: exercise)
  end

  test "edit: redirects if track not joined" do
    user = create :user
    track = create :track
    exercise = create :practice_exercise, track: track, slug: "hello-world"

    sign_in!(user)

    get edit_track_exercise_url(track, exercise)
    assert_redirected_to action: :show
  end
end
