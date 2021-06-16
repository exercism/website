require "test_helper"

class ContributorTeamTest < ActiveSupport::TestCase
  test "wired in correctly" do
    track = create :track
    team = create :contributor_team, track: track

    assert_equal track, team.track
  end
end
