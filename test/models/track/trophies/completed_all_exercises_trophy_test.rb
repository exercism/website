require "test_helper"

class Track::Trophies::CompletedAllExercisesTrophyTest < ActiveSupport::TestCase
  test "award?" do
    user = create :user
    track = create :track
    trophy = create :completed_all_exercises_trophy

    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_2 = create(:concept_exercise, :random_slug, track:)
    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_2 = create(:practice_exercise, :random_slug, track:)

    create(:user_track, user:, track:)

    # We need to get hold of the user track like this as otherwise
    # we'd end up with the code being tested using a different,
    # cached version of the user track and we could not reset the
    # summary data
    user_track = UserTrack.for!(user, track)

    # Started
    ps_1 = create(:practice_solution, exercise: pe_1, user:)

    # Iterated
    ps_2 = create(:practice_solution, exercise: pe_2, user:)
    cs_3 = create(:concept_solution, exercise: ce_1, user:)

    # Completed
    create(:concept_solution, exercise: ce_2, completed_at: Time.current, user:)

    # Just one concept exercise completed doesn't count
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Both concept exercises completed doesn't count
    cs_3.update(completed_at: Time.current)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Just one practice exercise completed doesn't count
    ps_1.update(completed_at: Time.current)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # All exercises completed counts
    ps_2.update(completed_at: Time.current)
    user_track.reset_summary!
    assert trophy.award?(user, track)
  end
end
