require "test_helper"

class Track::Trophies::Shared::CompletedFiveDifficultExercisesTrophyTest < ActiveSupport::TestCase
  test "award?" do
    user = create :user
    track = create :track
    trophy = create :completed_five_difficult_exercises_trophy

    create(:user_track, user:, track:)

    # We need to get hold of the user track like this as otherwise
    # we'd end up with the code being tested using a different,
    # cached version of the user track and we could not reset the
    # summary data
    user_track = UserTrack.for!(user, track)

    easy_exercises = create_list(:practice_exercise, 5, :random_slug, track:, difficulty: 2)
    medium_exercises = create_list(:practice_exercise, 5, :random_slug, track:, difficulty: 5)
    hard_exercises = create_list(:practice_exercise, 5, :random_slug, track:, difficulty: 8)

    # Completing five easy solutions does not count
    easy_exercises.each { |exercise| create(:practice_solution, :completed, exercise:, user:) }
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Completing five medium solutions does not count
    medium_exercises.each { |exercise| create(:practice_solution, :completed, exercise:, user:) }
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Completing four medium solutions does not count
    hard_exercises[0..3].each { |exercise| create(:practice_solution, :completed, exercise:, user:) }
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Starting fifth medium solution does not count
    solution = create(:practice_solution, :started, exercise: hard_exercises[4], user:)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Iterating fifth medium solution does not count
    solution.update(status: :iterated)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Completing fifth medium solution counts
    solution.update(completed_at: Time.current)
    user_track.reset_summary!
    assert trophy.award?(user, track)
  end
end
