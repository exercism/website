require "test_helper"

class ContributorTeam::Membership::DestroyTest < ActiveSupport::TestCase
  test "removes user from team" do
    user = create :user
    team = create :contributor_team
    create :contributor_team_membership, user: user, team: team

    # Sanity check
    assert_includes user.reload.teams, team
    assert_includes team.members, user

    ContributorTeam::Membership::Destroy.(user, team)

    refute_includes user.teams, team
    refute_includes team.members, user
  end

  test "idempotent" do
    user = create :user
    team = create :contributor_team

    assert_idempotent_command do
      ContributorTeam::Membership::Create.(
        user,
        team,
        seniority: :junior,
        visible: true
      )
    end
  end
end
