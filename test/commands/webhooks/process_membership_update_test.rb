require "test_helper"

class Webhooks::ProcessMembershipUpdateTest < ActiveSupport::TestCase
  test "add team member when action is 'added'" do
    user_id = 12_348_521
    team_name = 'team11'
    org = 'exercism'

    Github::Organization.any_instance.stubs(:name).returns(org)

    Webhooks::ProcessMembershipUpdate.('added', user_id, team_name, org)

    assert Github::TeamMember.where(user_id:, team_name:).exists?
  end

  test "removes team member when action is 'removed'" do
    user_id = 12_348_521
    team_name = 'team11'
    org = 'exercism'
    create(:github_team_member, user_id:, team_name:)

    Github::Organization.any_instance.stubs(:name).returns(org)

    Webhooks::ProcessMembershipUpdate.('removed', user_id, team_name, org)

    refute Github::TeamMember.where(user_id:, team_name:).exists?
  end

  test "does not do anything if organization does not match" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    Github::TeamMember::Create.expects(:call).never
    Github::TeamMember::Destroy.expects(:call).never

    Webhooks::ProcessMembershipUpdate.('add', 12_348_521, 'team11', 'invalid-org')
  end

  test "does not do anything if action is unknown" do
    Github::TeamMember::Create.expects(:call).never
    Github::TeamMember::Destroy.expects(:call).never

    Webhooks::ProcessMembershipUpdate.('invalid-action', 12_348_521, 'team11', 'exercism')
  end
end
