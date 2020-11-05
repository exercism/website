require "test_helper"

class Tracks::ExercisesControllerTest < ActionDispatch::IntegrationTest
  test "index: renders correctly for external" do
    # TODO: Unskip when devise is added
    skip

    track = create :track

    get track_exercises_url(track)
    assert_template "tracks/exercises/index/external"
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
    track = create :track

    sign_in!

    get track_exercises_url(track)
    assert_template "tracks/exercises/index"
  end

  test "concept/show: renders correctly for external" do
    # TODO: Unskip when devise is added
    skip

    track = create :track
    exercise = create :concept_exercise, track: track

    get track_exercise_url(track, exercise)
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
    exercise = create :concept_exercise

    sign_in!

    get track_exercise_url(exercise.track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "practice/show: renders correctly for external" do
    # TODO: Unskip when devise is added
    skip

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
    track = create :track
    exercise = create :practice_exercise, track: track

    sign_in!

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end
end
