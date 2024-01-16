require "test_helper"

class Track::Trophies::CompletedTwentyExercisesTrophyTest < ActiveSupport::TestCase
  test "award?" do
    user = create :user
    track = create :track
    trophy = create :completed_twenty_exercises_trophy

    exercises = create_list(:practice_exercise, 20, :random_slug, track:)
    create(:user_track, user:, track:)

    # We need to get hold of the user track like this as otherwise
    # we'd end up with the code being tested using a different,
    # cached version of the user track and we could not reset the
    # summary data
    user_track = UserTrack.for!(user, track)

    # Completing 19 solutions does not count
    exercises[0..18].each { |exercise| create(:practice_solution, :completed, exercise:, user:) }
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Starting 20th solution does not count
    solution = create(:practice_solution, :started, exercise: exercises[19], user:)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Iterating 20th solution does not count
    solution.update(status: :iterated)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Completing 20th solution counts
    solution.update(completed_at: Time.current)
    user_track.reset_summary!
    assert trophy.award?(user, track)
  end
end
