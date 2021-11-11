require "test_helper"

class SyncTeamPermissionsJobTest < ActiveJob::TestCase
  test "updates all teams" do
    team_1 = create :contributor_team, github_name: 'csharp', track: (create :track, slug: 'csharp')
    team_2 = create :contributor_team, github_name: 'ruby', track: (create :track, slug: 'ruby')
    team_3 = create :contributor_team, github_name: 'configlet', track: nil

    ContributorTeam::UpdateReviewersTeamPermissions.expects(:call).with(team_1)
    ContributorTeam::UpdateReviewersTeamPermissions.expects(:call).with(team_2)
    ContributorTeam::UpdateReviewersTeamPermissions.expects(:call).with(team_3)

    SyncTeamPermissionsJob.perform_now
  end

  test "continues updating if team update fails" do
    team_1 = create :contributor_team, github_name: 'csharp', track: (create :track, slug: 'csharp')
    team_2 = create :contributor_team, github_name: 'ruby', track: (create :track, slug: 'ruby')
    team_3 = create :contributor_team, github_name: 'configlet', track: nil

    ContributorTeam::UpdateReviewersTeamPermissions.stubs(:call).with(team_1).raises(RuntimeError)
    ContributorTeam::UpdateReviewersTeamPermissions.expects(:call).with(team_2)
    ContributorTeam::UpdateReviewersTeamPermissions.expects(:call).with(team_3)

    SyncTeamPermissionsJob.perform_now
  end
end
