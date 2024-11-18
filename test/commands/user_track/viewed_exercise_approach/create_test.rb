require "test_helper"

class UserTrack::ViewedExerciseApproach::CreateTest < ActiveSupport::TestCase
  test "returns existing record" do
    user = create :user
    track = create :track
    approach = create(:exercise_approach, track:)

    expected = create(:user_track_viewed_exercise_approach, user:, track:, approach:)
    assert_equal expected, UserTrack::ViewedExerciseApproach::Create.(user, track, approach)
  end

  test "creates new record" do
    user = create :user
    track = create :track
    approach = create(:exercise_approach, track:)

    actual = UserTrack::ViewedExerciseApproach::Create.(user, track, approach)
    assert_equal user, actual.user
    assert_equal track, actual.track
    assert_equal approach, actual.approach
  end

  test "awards read five approaches trophy when now having read five" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:)

    perform_enqueued_jobs do
      create_list(:exercise_approach, 4, exercise:) do |approach|
        create(:user_track_viewed_exercise_approach, user:, track:, approach:)
      end
    end

    refute_includes user.reload.trophies.map(&:class), Track::Trophies::ReadFiveApproachesTrophy

    approach = create(:exercise_approach, exercise:)

    perform_enqueued_jobs do
      UserTrack::ViewedExerciseApproach::Create.(user, track, approach)
    end

    assert_includes user.reload.trophies.map(&:class), Track::Trophies::ReadFiveApproachesTrophy
  end
end
