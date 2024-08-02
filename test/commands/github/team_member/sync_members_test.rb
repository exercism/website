require "test_helper"

class Github::TeamMember::SyncMembersTest < ActiveSupport::TestCase
  test "adds new members" do
    team_members = { 'ruby' => [12_412, 82_462], 'fsharp' => [12_412, 56_653] }
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    create(:user, uid: '12412')
    create(:user, uid: '82462')
    create(:user, uid: '56653')
    Github::TeamMember::Destroy.expects(:call).never

    Github::TeamMember::SyncMembers.()

    assert ::Github::TeamMember.where(team_name: 'ruby', user_id: '12412').exists?
    assert ::Github::TeamMember.where(team_name: 'ruby', user_id: '82462').exists?
    assert ::Github::TeamMember.where(team_name: 'fsharp', user_id: '12412').exists?
    assert ::Github::TeamMember.where(team_name: 'fsharp', user_id: '56653').exists?
  end

  test "keeps existing members" do
    team_members = { 'ruby' => [12_412] }
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    create(:user, uid: '12412')
    create :github_team_member, team_name: 'ruby', user_id: '12412'

    Github::TeamMember::SyncMembers.()

    assert_equal 1, ::Github::TeamMember.count
    assert ::Github::TeamMember.where(team_name: 'ruby', user_id: '12412').exists?
  end

  test "removes former members" do
    team_members = { 'ruby' => [82_462], 'fsharp' => [12_412] }
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    create(:user, uid: '56653')
    create(:user, uid: '82462')
    create(:user, uid: '12412')
    create :github_team_member, team_name: 'ruby', user_id: '56653'

    Github::TeamMember::SyncMembers.()

    assert_equal 2, ::Github::TeamMember.count
    refute ::Github::TeamMember.where(team_name: 'ruby', user_id: '56653').exists?
    assert ::Github::TeamMember.where(team_name: 'ruby', user_id: '82462').exists?
    assert ::Github::TeamMember.where(team_name: 'fsharp', user_id: '12412').exists?
  end

  test "delete when group does not exist" do
    team_members = { 'ruby' => [82_462], 'fsharp' => [12_412] }
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    create(:user, uid: '12412')
    create(:user, uid: '82462')
    create(:user, uid: '56653')
    create :github_team_member, team_name: 'prolog', user_id: '56653'

    Github::TeamMember::SyncMembers.()

    assert_equal 2, ::Github::TeamMember.count
    refute ::Github::TeamMember.where(team_name: 'prolog', user_id: '56653').exists?
    assert ::Github::TeamMember.where(team_name: 'ruby', user_id: '82462').exists?
    assert ::Github::TeamMember.where(team_name: 'fsharp', user_id: '12412').exists?
  end
end
