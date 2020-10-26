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

  test "show: renders correctly for external" do
    # TODO: Unskip when devise is added
    skip

    track = create :track
    exercise = create :practice_exercise, track: track

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "show: renders correctly for joined" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track

    sign_in!(user)

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end

  test "show: renders correctly for unjoined" do
    track = create :track
    exercise = create :practice_exercise, track: track

    sign_in!

    get track_exercise_url(track, exercise)
    assert_template "tracks/exercises/show"
  end
end
