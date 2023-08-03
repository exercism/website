require "test_helper"

class UserTrack::ViewedCommunitySolution::CreateTest < ActiveSupport::TestCase
  test "returns existing record" do
    user = create :user
    track = create :track
    solution = create(:practice_solution, user:, track:)
    expected = create(:user_track_viewed_community_solution, user:, track:, solution:)

    actual = UserTrack::ViewedCommunitySolution::Create.(user, track, solution)
    assert_equal expected, actual
  end

  test "creates new record" do
    user = create :user
    track = create :track
    solution = create(:practice_solution, user:, track:)

    actual = UserTrack::ViewedCommunitySolution::Create.(user, track, solution)
    assert_equal user, actual.user
    assert_equal track, actual.track
    assert_equal solution, actual.solution
  end

  test "awards read fifty community solutions trophy when now having read fifty" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)

    create_list(:practice_solution, 49, user:, track:) do |solution|
      create(:user_track_viewed_community_solution, user:, track:, solution:)
    end

    refute_includes user.reload.trophies.map(&:class), Track::Trophies::General::ReadFiftyCommunitySolutionsTrophy

    solution = create(:practice_solution, user:, track:)

    perform_enqueued_jobs do
      UserTrack::ViewedCommunitySolution::Create.(user, track, solution)
    end

    assert_includes user.reload.trophies.map(&:class), Track::Trophies::General::ReadFiftyCommunitySolutionsTrophy
  end
end
