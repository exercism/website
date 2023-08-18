require "test_helper"

class Track::Trophies::CompletedLearningModeTrophyTest < ActiveSupport::TestCase
  test "award?" do
    user = create :user
    track = create :track
    trophy = create :completed_learning_mode_trophy

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

    # Practice exercises completed don't count
    ps_1.update(completed_at: Time.current)
    ps_2.update(completed_at: Time.current)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Both concept exercises completed counts
    cs_3.update(completed_at: Time.current)
    user_track.reset_summary!
    assert trophy.award?(user, track)
  end

  test "reseed! sets valid_track_slugs to tracks with learning mode enabled" do
    track = create :track, course: false
    trophy = create :completed_learning_mode_trophy

    # Track is not valid if learning mode is disabled
    assert_empty trophy.valid_track_slugs

    # Track is valid if learning mode is enabled
    track.update(course: true)
    trophy.reseed!
    assert_equal [track.slug], trophy.valid_track_slugs

    # Ignore other track with learning mode disabled
    other_track = create :track, slug: 'fsharp', course: false
    trophy.reseed!
    assert_equal [track.slug], trophy.valid_track_slugs

    # Ignore all tracks with learning mode enabled
    other_track.update(course: true)
    trophy.reseed!
    assert_equal [track.slug, other_track.slug].sort, trophy.valid_track_slugs.sort
  end
end
