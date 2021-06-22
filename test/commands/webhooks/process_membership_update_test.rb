require "test_helper"

class Webhooks::ProcessMembershipUpdateTest < ActiveSupport::TestCase
  test "adds membership if action is 'added' and organization is exercism" do
    user = create :user, github_username: 'user22'
    team = create :contributor_team, github_name: 'team11'
    Github::Team.any_instance.expects(:add_member).with('user22')

    Webhooks::ProcessMembershipUpdate.('added', 'user22', 'team11', 'exercism')

    assert ContributorTeam::Membership.where(user: user, team: team).exists?
  end

  test "does not add membership if action is 'added' and organization is not exercism" do
    user = create :user, github_username: 'user22'
    team = create :contributor_team, github_name: 'team11'

    Webhooks::ProcessMembershipUpdate.('added', 'user22', 'team11', 'other-org')

    refute ContributorTeam::Membership.where(user: user, team: team).exists?
  end

  test "does not add membership if action is not 'added'" do
    user = create :user, github_username: 'user22'
    team = create :contributor_team, github_name: 'team11'

    Webhooks::ProcessMembershipUpdate.('other-action', 'user22', 'team11', 'exercism')

    refute ContributorTeam::Membership.where(user: user, team: team).exists?
  end

  test "removes membership if action is 'removed' and organization is exercism" do
    user = create :user, github_username: 'user22'
    team = create :contributor_team, github_name: 'team11'
    create :contributor_team_membership, team: team, user: user
    Github::Team.any_instance.expects(:remove_member).with('user22')

    stub_request(:post, "https://api.github.com/graphql").
      to_return(
        status: 200,
        body: { data: { organization: { teams: { totalCount: 0 } } } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    Webhooks::ProcessMembershipUpdate.('removed', 'user22', 'team11', 'exercism')

    refute ContributorTeam::Membership.where(user: user, team: team).exists?
  end

  test "does not remove membership if action is 'removed' and organization is not exercism" do
    user = create :user, github_username: 'user22'
    team = create :contributor_team, github_name: 'team11'
    create :contributor_team_membership, team: team, user: user

    Webhooks::ProcessMembershipUpdate.('removed', 'user22', 'team11', 'other-org')

    assert ContributorTeam::Membership.where(user: user, team: team).exists?
  end

  test "does not remove membership if action is not 'removed'" do
    user = create :user, github_username: 'user22'
    team = create :contributor_team, github_name: 'team11'
    create :contributor_team_membership, team: team, user: user

    Webhooks::ProcessMembershipUpdate.('other-action', 'user22', 'team11', 'other-org')

    assert ContributorTeam::Membership.where(user: user, team: team).exists?
  end
end
