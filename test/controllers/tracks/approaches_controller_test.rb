require "test_helper"

class Tracks::ApproachesControllerTest < ActionDispatch::IntegrationTest
  test "index: redirects to dig_deeper" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    get track_exercise_approaches_url(track, exercise)

    assert_redirected_to track_exercise_dig_deeper_url(track, exercise)
  end

  test "show: renders correctly for external" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)

    get track_exercise_approach_url(track, exercise, approach)

    assert_template "tracks/approaches/show"
  end

  test "show: redirects when exercise is hello-world" do
    track = create :track
    exercise = create(:hello_world_exercise, track:)
    approach = create(:exercise_approach, exercise:)

    get track_exercise_approach_url(track, exercise, approach)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "show: redirects when not iterated and not unlocked help" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)
    create(:concept_solution, user:, exercise:)

    sign_in!(user)

    get track_exercise_approach_url(track, exercise, approach)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "show: 404s when track does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)

    sign_in!(user)

    get track_exercise_approach_url('unknown', exercise, approach)

    assert_rendered_404
  end

  test "show: 404s when exercise does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)

    sign_in!(user)

    get track_exercise_approach_url(track, 'unknown', approach)

    assert_rendered_404
  end

  test "show: 404s when approach does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)

    sign_in!(user)

    get track_exercise_approach_url(track, exercise, 'unknown')

    assert_rendered_404
  end

  test "show: renders when not iterated but unlocked help" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)
    create :concept_solution, user:, exercise:, unlocked_help: true

    sign_in!(user)

    get track_exercise_approach_url(track, exercise, approach)

    assert_template "tracks/approaches/show"
  end

  test "show: renders when iterated" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)
    solution = create :concept_solution, user:, exercise:, unlocked_help: true
    create(:iteration, solution:, user:)

    sign_in!(user)

    get track_exercise_approach_url(track, exercise, approach)

    assert_template "tracks/approaches/show"
  end

  test "show: registers approach as viewed" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)
    solution = create :concept_solution, user:, exercise:, unlocked_help: true
    create(:iteration, solution:, user:)

    UserTrack::ViewedExerciseApproach::Create.expects(:defer).with(user, track, approach)

    sign_in!(user)
    get track_exercise_approach_url(track, exercise, approach)
  end

  test "show: does not register community solution as viewed for non-logged in user" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)

    UserTrack::ViewedExerciseApproach::Create.expects(:defer).never

    get track_exercise_approach_url(track, exercise, approach)
  end
end
