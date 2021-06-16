require "test_helper"

class ContributorTeamTest < ActiveSupport::TestCase
  test "wired in correctly" do
    track = create :track
    team = create :contributor_team, track: track

    assert_equal track, team.track
  end

  test "members" do
    team = create :contributor_team
    user_1 = create :user
    user_2 = create :user
    create :contributor_team_membership, team: team, user: user_1
    create :contributor_team_membership, team: team, user: user_2

    assert_equal [user_1, user_2], team.members
  end
end
