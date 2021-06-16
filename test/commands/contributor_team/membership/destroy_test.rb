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

  test "removes user from team of which user is not member" do
    user = create :user
    team = create :contributor_team

    # Sanity check
    assert_empty user.roles
    refute_includes user.reload.teams, team
    refute_includes team.members, user

    ContributorTeam::Membership::Destroy.(user, team)

    assert_empty user.roles
    refute_includes user.teams, team
    refute_includes team.members, user
  end

  test "does not remove user from other team" do
    user = create :user
    team = create :contributor_team
    other_team = create :contributor_team, :random
    create :contributor_team_membership, user: user, team: team
    create :contributor_team_membership, user: user, team: other_team

    ContributorTeam::Membership::Destroy.(user, team)

    assert_includes user.teams, other_team
    assert_includes other_team.members, user
  end

  test "removes maintainer role when no longer a member of a track_maintainers team" do
    user = create :user, roles: [:reviewer]
    team = create :contributor_team, type: :track_maintainers
    create :contributor_team_membership, user: user, team: team

    ContributorTeam::Membership::Destroy.(user, team)

    refute_includes user.roles, :maintainer
  end

  test "removes reviewer role when no longer a member of a reviewers team" do
    user = create :user, roles: [:reviewer]
    team = create :contributor_team, type: :reviewers
    create :contributor_team_membership, user: user, team: team

    ContributorTeam::Membership::Destroy.(user, team)

    refute_includes user.roles, :reviewer
  end

  test "does not remove maintainer role when still member of a track_maintainers team" do
    user = create :user, roles: [:maintainer]
    team = create :contributor_team, type: :track_maintainers
    other_team = create :contributor_team, :random, type: :track_maintainers
    create :contributor_team_membership, user: user, team: team
    create :contributor_team_membership, user: user, team: other_team

    ContributorTeam::Membership::Destroy.(user, team)

    assert_includes user.roles, :maintainer
  end

  test "does not remove reviewer role when still member of a reviewers team" do
    user = create :user, roles: [:reviewer]
    team = create :contributor_team, type: :reviewers
    other_team = create :contributor_team, :random, type: :reviewers
    create :contributor_team_membership, user: user, team: team
    create :contributor_team_membership, user: user, team: other_team

    ContributorTeam::Membership::Destroy.(user, team)

    assert_includes user.roles, :reviewer
  end

  test "keeps existing roles" do
    user = create :user, roles: %i[admin maintainer reviewer]
    team = create :contributor_team, type: :reviewers
    create :contributor_team_membership, user: user, team: team

    ContributorTeam::Membership::Destroy.(user, team)

    assert_equal 2, user.roles.size
    assert_includes user.roles, :admin
    assert_includes user.roles, :maintainer
  end
end
