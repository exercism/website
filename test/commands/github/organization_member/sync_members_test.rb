require "test_helper"

class Github::OrganizationMember::SyncMembersTest < ActiveSupport::TestCase
  test "adds new members" do
    Github::Organization.any_instance.stubs(:member_usernames).returns(['ErikSchierboom'])
    Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom'])

    Github::OrganizationMember::SyncMembers.()

    member = ::Github::OrganizationMember.find_by(username: 'ErikSchierboom')
    refute member.alumnus
  end

  test "keeps existing members" do
    Github::Organization.any_instance.stubs(:member_usernames).returns(['ErikSchierboom'])
    Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom'])

    member = create :github_organization_member, username: 'ErikSchierboom'

    Github::OrganizationMember::SyncMembers.()

    refute member.alumnus
  end

  test "set alumnus to false for existing members" do
    Github::Organization.any_instance.stubs(:member_usernames).returns(['ErikSchierboom'])
    Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom'])

    member = create :github_organization_member, username: 'ErikSchierboom', alumnus: true

    Github::OrganizationMember::SyncMembers.()

    refute member.reload.alumnus
  end

  test "makes missing members alumnus" do
    member = create :github_organization_member, username: 'iHiD', alumnus: false

    # Sanity check
    refute member.alumnus

    Github::Organization.any_instance.stubs(:member_usernames).returns(['ErikSchierboom'])
    Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom'])
    Github::Organization.any_instance.stubs(:remove_member)

    Github::OrganizationMember::SyncMembers.()

    assert member.reload.alumnus
  end

  test "imports all members" do
    Github::Organization.any_instance.stubs(:member_usernames).returns(%w[ErikSchierboom DJ iHiD])
    Github::Organization.any_instance.stubs(:team_member_usernames).returns(%w[ErikSchierboom DJ iHiD])

    Github::OrganizationMember::SyncMembers.()

    members = ::Github::OrganizationMember.all
    assert_equal 3, members.size
    assert_equal 'ErikSchierboom', members.first.username
    assert_equal 'DJ', members.second.username
    assert_equal 'iHiD', members.third.username
  end

  test "removes members without team membership from organization" do
    create :github_organization_member, username: 'DJ'
    create :github_organization_member, username: 'ErikSchierboom'
    create :github_organization_member, username: 'iHiD'

    Github::Organization.any_instance.stubs(:member_usernames).returns(%w[ErikSchierboom DJ iHiD])
    Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom'])

    Github::Organization.any_instance.expects(:remove_member).with('DJ')
    Github::Organization.any_instance.expects(:remove_member).with('iHiD')

    Github::OrganizationMember::SyncMembers.()
  end

  test "does not remove members with team membership from organization" do
    create :github_organization_member, username: 'ErikSchierboom'

    Github::Organization.any_instance.stubs(:member_usernames).returns(['ErikSchierboom'])
    Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom'])

    Github::Organization.any_instance.expects(:remove_member).with('ErikSchierboom').never

    Github::OrganizationMember::SyncMembers.()
  end
end
