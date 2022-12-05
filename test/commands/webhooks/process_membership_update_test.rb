require "test_helper"

class Webhooks::ProcessMembershipUpdateTest < ActiveSupport::TestCase
  test "add team member when action is 'added'" do
    username = 'user22'
    team = 'team11'
    org = 'exercism'

    Github::Organization.any_instance.stubs(:name).returns(org)

    Webhooks::ProcessMembershipUpdate.('added', username, team, org)

    assert Github::TeamMember.where(username:, team:).exists?
  end

  test "removes team member when action is 'removed'" do
    username = 'user22'
    team = 'team11'
    org = 'exercism'
    create :github_team_member, username: username, team: team

    Github::Organization.any_instance.stubs(:name).returns(org)

    Webhooks::ProcessMembershipUpdate.('removed', username, team, org)

    refute Github::TeamMember.where(username:, team:).exists?
  end

  test "does not do anything if organization does not match" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    Github::TeamMember::Create.expects(:call).never
    Github::TeamMember::Destroy.expects(:call).never

    Webhooks::ProcessMembershipUpdate.('add', 'user22', 'team11', 'invalid-org')
  end

  test "does not do anything if action is unknown" do
    Github::TeamMember::Create.expects(:call).never
    Github::TeamMember::Destroy.expects(:call).never

    Webhooks::ProcessMembershipUpdate.('invalid-action', 'user22', 'team11', 'exercism')
  end
end
