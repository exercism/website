require "test_helper"

class Track::Trophies::CompletedFiftyPercentOfExercisesTrophyTest < ActiveSupport::TestCase
  test "award?" do
    user = create :user
    track = create :track
    trophy = create :completed_fifty_percent_of_exercises_trophy

    exercises = create_list(:practice_exercise, 5, :random_slug, track:)

    create(:user_track, user:, track:)

    # We need to get hold of the user track like this as otherwise
    # we'd end up with the code being tested using a different,
    # cached version of the user track and we could not reset the
    # summary data
    user_track = UserTrack.for!(user, track)

    # Completing less than half of the exercises
    create(:practice_solution, :completed, exercise: exercises[0], user:)
    create(:practice_solution, :completed, exercise: exercises[1], user:)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Starting exercise does not count
    solution = create(:practice_solution, :started, exercise: exercises[2], user:)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Iterating exercise does not count
    solution.update(status: :iterated)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Completing exercise counts
    solution.update(completed_at: Time.current)
    user_track.reset_summary!
    assert trophy.award?(user, track)
  end
end
