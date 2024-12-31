require "test_helper"

class Track::Trophies::ReadFiftyCommunitySolutionsTrophyTest < ActiveSupport::TestCase
  test "award?" do
    user = create :user
    other_user = create :user
    track = create :track
    other_track = create :track, slug: 'kotlin'
    trophy = create :read_fifty_community_solutions_trophy

    exercise = create(:practice_exercise, :random_slug, track:)
    other_exercise = create(:practice_exercise, :random_slug, track: other_track)

    create(:user_track, user:, track:)
    create(:user_track, user:, track: other_track)

    # Don't award trophy if no community solutions have been read
    refute trophy.award?(user, track)

    # Don't award trophy if less than fifty community solutions in the track have been read
    create_list(:practice_solution, 30, exercise:) do |solution|
      create(:user_track_viewed_community_solution, user:, track:, solution:)
    end
    refute trophy.award?(user, track)

    # Don't award trophy if other user has read fifty community solutions in the track
    create_list(:practice_solution, 50, exercise:) do |solution|
      create(:user_track_viewed_community_solution, user: other_user, track:, solution:)
    end
    refute trophy.award?(user, track)

    # Don't count viewed community solutions for other track
    create_list(:practice_solution, 60, exercise: other_exercise) do |solution|
      create(:user_track_viewed_community_solution, user:, track: other_track, solution:)
    end
    refute trophy.award?(user, track)

    # Award trophy when fifty community solutions in the track have been read
    create_list(:practice_solution, 20, exercise:) do |solution|
      create(:user_track_viewed_community_solution, user:, track:, solution:)
    end
    assert trophy.award?(user, track)
  end
end
