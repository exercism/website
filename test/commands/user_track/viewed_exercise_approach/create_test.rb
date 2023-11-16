require "test_helper"

class UserTrack::ViewedExerciseApproach::CreateTest < ActiveSupport::TestCase
  test "returns existing record" do
    user = create :user
    track = create :track
    exercise_approach = create(:exercise_approach, track:)

    expected = create(:user_track_viewed_exercise_approach, user:, track:, exercise_approach:)
    assert_equal expected, UserTrack::ViewedExerciseApproach::Create.(user, track, exercise_approach)
  end

  test "creates new record" do
    user = create :user
    track = create :track
    exercise_approach = create(:exercise_approach, track:)

    actual = UserTrack::ViewedExerciseApproach::Create.(user, track, exercise_approach)
    assert_equal user, actual.user
    assert_equal track, actual.track
    assert_equal exercise_approach, actual.exercise_approach
  end
end
