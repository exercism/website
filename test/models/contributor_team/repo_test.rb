require "test_helper"

class ContributorTeam::RepoTest < ActiveSupport::TestCase
  test "wired in correctly" do
    team = create :contributor_team
    repo = create :contributor_team_repo, team: team

    assert_equal team, repo.team
  end
end
