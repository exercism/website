require "test_helper"

class Track::Trophies::ReadFiveApproachesTrophyTest < ActiveSupport::TestCase
  test "award?" do
    user = create :user
    other_user = create :user
    track = create :track
    other_track = create :track, slug: 'kotlin'
    trophy = create :read_five_approaches_trophy

    exercise = create(:practice_exercise, :random_slug, track:)
    other_exercise = create(:practice_exercise, :random_slug, track: other_track)

    # Don't award trophy if no approaches have been read
    refute trophy.award?(user, track)

    # Don't award trophy if less than five approaches
    create_list(:exercise_approach, 4, :random, exercise:) do |approach|
      create(:user_track_viewed_exercise_approach, user:, track:, approach:)
    end
    refute trophy.award?(user, track)

    # Don't award trophy if other user has read five approaches in the track
    create_list(:exercise_approach, 6, :random, exercise:) do |approach|
      create(:user_track_viewed_exercise_approach, user: other_user, track:, approach:)
    end
    refute trophy.award?(user, track)

    # Don't count viewed approaches for other track
    create_list(:exercise_approach, 7, :random, exercise: other_exercise) do |approach|
      create(:user_track_viewed_exercise_approach, user:, track: other_track, approach:)
    end
    refute trophy.award?(user, track)

    # Award trophy when five approaches solutions in the track have been read
    create(:exercise_approach, exercise:) do |approach|
      create(:user_track_viewed_exercise_approach, user:, track:, approach:)
    end
    assert trophy.award?(user, track)
  end

  test "reseed! sets valid_track_slugs to tracks with at least five approaches" do
    trophy = create :read_five_approaches_trophy

    # Track is not valid if it doesn't have any approaches
    track = create :track, :random_slug
    trophy.reseed!
    assert_empty trophy.valid_track_slugs

    # Four approaches is not enough
    create_list(:exercise_approach, 4, exercise: create(:practice_exercise, :random_slug, track:))
    trophy.reseed!
    assert_empty trophy.valid_track_slugs

    # Five approaches is enough
    create(:exercise_approach, exercise: create(:practice_exercise, :random_slug, track:))
    trophy.reseed!
    assert_equal [track.slug], trophy.valid_track_slugs

    # Include all tracks with five approaches
    other_track = create :track, :random_slug
    create_list(:exercise_approach, 6, exercise: create(:practice_exercise, :random_slug, track: other_track))
    trophy.reseed!
    assert_equal [track.slug, other_track.slug].sort, trophy.valid_track_slugs.sort
  end
end
