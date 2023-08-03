require "test_helper"

class Track::Trophies::General::MentoredTrophyTest < ActiveSupport::TestCase
  test "award?" do
    # Get set up
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    trophy = create :mentored_trophy

    # A random discussion for this track shouldn't count
    solution = create(:practice_solution, track:)
    create(:mentor_discussion, :finished, solution:)
    refute trophy.award?(user, track)

    # A discussion for this user on a different track shouldn't count
    solution = create :practice_solution, user:, track: create(:track, slug: :js)
    create(:mentor_discussion, :finished, solution:)
    refute trophy.award?(user, track)

    # An unfinished discussion shouldn't count
    solution = create(:practice_solution, user:, track:)
    create(:mentor_discussion, solution:)
    refute trophy.award?(user, track)

    # A unfinished discussion shouldn't count
    solution = create(:practice_solution, user:, track:)
    create(:mentor_discussion, :finished, solution:)
    assert trophy.award?(user, track)
  end
end
