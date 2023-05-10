require "test_helper"

class Tracks::DigDeeperControllerTest < ActionDispatch::IntegrationTest
  test "show: 404s when track does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)

    sign_in!(user)

    get track_exercise_dig_deeper_url('unknown', exercise)

    assert_rendered_404
  end

  test "show: 404s when exercise does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)

    sign_in!(user)

    get track_exercise_dig_deeper_url(track, 'unknown')

    assert_rendered_404
  end

  test "show: renders correctly for external" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    get track_exercise_dig_deeper_url(track, exercise)

    assert_template "tracks/dig_deeper/show"
  end

  test "show: redirects when exercise is hello-world" do
    track = create :track
    exercise = create(:hello_world_exercise, track:)

    get track_exercise_dig_deeper_url(track, exercise)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "show: redirects when not iterated and not unlocked help" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    create(:concept_solution, user:, exercise:)

    sign_in!(user)

    get track_exercise_dig_deeper_url(track, exercise)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "show: renders when not iterated but unlocked help" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    create :concept_solution, user:, exercise:, unlocked_help: true

    sign_in!(user)

    get track_exercise_dig_deeper_url(track, exercise)

    assert_template "tracks/dig_deeper/show"
  end

  test "show: renders when iterated" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    solution = create :concept_solution, user:, exercise:, unlocked_help: true
    create(:iteration, solution:, user:)

    sign_in!(user)

    get track_exercise_dig_deeper_url(track, exercise)

    assert_template "tracks/dig_deeper/show"
  end

  test "tooltip_locked: renders when external" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    get tooltip_locked_track_exercise_dig_deeper_url(track, exercise)

    assert_response :ok
  end

  test "tooltip_locked: renders when not iterated and not unlocked help" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    create(:concept_solution, user:, exercise:)

    sign_in!(user)

    get tooltip_locked_track_exercise_dig_deeper_url(track, exercise)

    assert_template "tracks/dig_deeper/tooltip_locked"
  end

  test "tooltip_locked: 404s when track does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)

    sign_in!(user)

    get tooltip_locked_track_exercise_dig_deeper_url('unknown', exercise)

    assert_rendered_404
  end

  test "tooltip_locked: 404s when exercise does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)

    sign_in!(user)

    get tooltip_locked_track_exercise_dig_deeper_url(track, 'unknown')

    assert_rendered_404
  end

  test "tooltip_locked: renders when not iterated but unlocked help" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    create :concept_solution, user:, exercise:, unlocked_help: true

    sign_in!(user)

    get tooltip_locked_track_exercise_dig_deeper_url(track, exercise)

    assert_template "tracks/dig_deeper/tooltip_locked"
  end

  test "tooltip_locked: renders when iterated" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    solution = create :concept_solution, user:, exercise:, unlocked_help: true
    create(:iteration, solution:, user:)

    sign_in!(user)

    get tooltip_locked_track_exercise_dig_deeper_url(track, exercise)

    assert_template "tracks/dig_deeper/tooltip_locked"
  end
end
