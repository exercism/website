require "test_helper"

class Github::TeamMember::SyncMembersTest < ActiveSupport::TestCase
  test "adds new members" do
    team_members = { 'ruby' => [12_412, 82_462], 'fsharp' => [12_412, 56_653] }
    user_1 = create(:user, uid: '12412')
    user_2 = create(:user, uid: '82462')
    user_3 = create(:user, uid: '56653')
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    Github::TeamMember::SyncMembers.()

    assert ::Github::TeamMember.where(team_name: 'ruby', user: user_1).exists?
    assert ::Github::TeamMember.where(team_name: 'ruby', user: user_2).exists?
    assert ::Github::TeamMember.where(team_name: 'fsharp', user: user_1).exists?
    assert ::Github::TeamMember.where(team_name: 'fsharp', user: user_3).exists?
  end

  test "keeps existing members" do
    team_members = { 'ruby' => [12_412] }
    user = create(:user, uid: '12412')
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    create(:github_team_member, team_name: 'ruby', user:)

    Github::TeamMember::SyncMembers.()

    assert_equal 1, ::Github::TeamMember.count
    assert ::Github::TeamMember.where(team_name: 'ruby', user:).exists?
  end

  test "removes former members" do
    team_members = { 'ruby' => [82_462], 'fsharp' => [12_412] }
    user_1 = create(:user, uid: '12412')
    user_2 = create(:user, uid: '82462')
    user_3 = create(:user, uid: '56653')
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    create :github_team_member, team_name: 'ruby', user: user_3

    Github::TeamMember::SyncMembers.()

    assert_equal 2, ::Github::TeamMember.count
    refute ::Github::TeamMember.where(team_name: 'ruby', user: user_3).exists?
    assert ::Github::TeamMember.where(team_name: 'ruby', user: user_2).exists?
    assert ::Github::TeamMember.where(team_name: 'fsharp', user: user_1).exists?
  end

  test "delete when group does not exist" do
    team_members = { 'ruby' => [82_462], 'fsharp' => [12_412] }
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    user_1 = create(:user, uid: '12412')
    user_2 = create(:user, uid: '82462')
    user_3 = create(:user, uid: '56653')
    create :github_team_member, team_name: 'prolog', user: user_3

    Github::TeamMember::SyncMembers.()

    assert_equal 2, ::Github::TeamMember.count
    refute ::Github::TeamMember.where(team_name: 'prolog', user: user_3).exists?
    assert ::Github::TeamMember.where(team_name: 'ruby', user_id: user_2).exists?
    assert ::Github::TeamMember.where(team_name: 'fsharp', user_id: user_1).exists?
  end
end
