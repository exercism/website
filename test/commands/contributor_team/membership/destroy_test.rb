require "test_helper"

class ContributorTeam::Membership::DestroyTest < ActiveSupport::TestCase
  test "removes user from team" do
    Github::Team.any_instance.stubs(:remove_membership)

    user = create :user, github_username: 'user22'
    team = create :contributor_team
    create :contributor_team_membership, user: user, team: team

    # Sanity check
    assert_includes user.reload.teams, team
    assert_includes team.members, user

    ContributorTeam::Membership::Destroy.(user, team)

    refute_includes user.teams, team
    refute_includes team.members, user
  end

  test "removes maintainer role when no longer a member of a maintainers team" do
    Github::Team.any_instance.stubs(:remove_membership)

    user = create :user, github_username: 'user22', roles: [:maintainer]
    team = create :contributor_team, type: :track_maintainers
    create :contributor_team_membership, user: user, team: team

    # Sanity check
    assert_includes user.roles, :maintainer

    ContributorTeam::Membership::Destroy.(user, team)

    refute_includes user.roles, :maintainer
  end

  test "removes reviewer role when no longer a member of a reviewers team" do
    Github::Team.any_instance.stubs(:remove_membership)

    user = create :user, github_username: 'user22', roles: [:reviewer]
    team = create :contributor_team, type: :reviewers
    create :contributor_team_membership, user: user, team: team

    # Sanity check
    assert_includes user.roles, :reviewer

    ContributorTeam::Membership::Destroy.(user, team)

    refute_includes user.roles, :reviewer
  end

  test "does not remove maintainer role when still member of a maintainers team" do
    Github::Team.any_instance.stubs(:remove_membership)

    user = create :user, github_username: 'user22', roles: [:maintainer]
    team = create :contributor_team, type: :track_maintainers
    second_team = create :contributor_team, type: :project_maintainers, github_name: 'configlet', track: nil
    create :contributor_team_membership, user: user, team: team
    create :contributor_team_membership, user: user, team: second_team

    ContributorTeam::Membership::Destroy.(user, team)

    assert_includes user.roles, :maintainer
  end

  test "keeps existing roles" do
    Github::Team.any_instance.stubs(:remove_membership)

    user = create :user, github_username: 'user22', roles: %i[admin maintainer reviewer]
    team = create :contributor_team, type: :track_maintainers
    create :contributor_team_membership, user: user, team: team

    # Sanity check
    assert_includes user.roles, :maintainer

    ContributorTeam::Membership::Destroy.(user, team)

    assert_equal 2, user.roles.size
    assert_includes user.roles, :admin
    assert_includes user.roles, :reviewer
    refute_includes user.roles, :maintainer
  end

  test "removes user from github team" do
    Github::Team.stubs(:organization).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/ruby-maintainers").
      to_return(status: 200, body: { id: 2_022_925 }.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:delete, "https://api.github.com/teams/2022925/memberships/user22").
      to_return(status: 200, body: "", headers: {})

    user = create :user, github_username: 'user22'
    team = create :contributor_team
    create :contributor_team_membership, user: user, team: team

    ContributorTeam::Membership::Destroy.(user, team)
  end
end
