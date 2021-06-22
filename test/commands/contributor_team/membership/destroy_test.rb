require "test_helper"

class ContributorTeam::Membership::DestroyTest < ActiveSupport::TestCase
  test "removes user from team" do
    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 2 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

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
    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 2 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

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
    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 2 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

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
    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 2 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    user = create :user, roles: [:reviewer]
    team = create :contributor_team, type: :track_maintainers
    create :contributor_team_membership, user: user, team: team

    ContributorTeam::Membership::Destroy.(user, team)

    refute_includes user.roles, :maintainer
  end

  test "removes reviewer role when no longer a member of a reviewers team" do
    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 2 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    user = create :user, roles: [:reviewer]
    team = create :contributor_team, type: :reviewers
    create :contributor_team_membership, user: user, team: team

    ContributorTeam::Membership::Destroy.(user, team)

    refute_includes user.roles, :reviewer
  end

  test "does not remove maintainer role when still member of a track_maintainers team" do
    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 2 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    user = create :user, roles: [:maintainer]
    team = create :contributor_team, type: :track_maintainers
    other_team = create :contributor_team, :random, type: :track_maintainers
    create :contributor_team_membership, user: user, team: team
    create :contributor_team_membership, user: user, team: other_team

    ContributorTeam::Membership::Destroy.(user, team)

    assert_includes user.roles, :maintainer
  end

  test "does not remove reviewer role when still member of a reviewers team" do
    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 2 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    user = create :user, roles: [:reviewer]
    team = create :contributor_team, type: :reviewers
    other_team = create :contributor_team, :random, type: :reviewers
    create :contributor_team_membership, user: user, team: team
    create :contributor_team_membership, user: user, team: other_team

    ContributorTeam::Membership::Destroy.(user, team)

    assert_includes user.roles, :reviewer
  end

  test "keeps existing roles" do
    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 2 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    user = create :user, roles: %i[admin maintainer reviewer]
    team = create :contributor_team, type: :reviewers
    create :contributor_team_membership, user: user, team: team

    ContributorTeam::Membership::Destroy.(user, team)

    assert_equal 2, user.roles.size
    assert_includes user.roles, :admin
    assert_includes user.roles, :maintainer
  end

  test "removes user from organization if no longer member of any team" do
    Exercism.config.stubs(:github_organization).returns('exercism')

    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 0 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/ruby-maintainers").
      to_return(status: 200, body: { id: 2_022_925 }.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:delete, "https://api.github.com/teams/2022925/memberships/").
      to_return(status: 200, body: "", headers: {})

    user = create :user
    team = create :contributor_team

    ContributorTeam::Membership::Destroy.(user, team)
  end

  test "does not remove user from organization if still member of at least one team" do
    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 1 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/ruby-maintainers").
      to_return(status: 200, body: { id: 2_022_925 }.to_json, headers: { 'Content-Type': 'application/json' })

    Github::Team.any_instance.expects(:remove_member).never

    user = create :user
    team = create :contributor_team

    ContributorTeam::Membership::Destroy.(user, team)
  end
end
