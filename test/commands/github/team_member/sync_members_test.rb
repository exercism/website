require "test_helper"

class Github::TeamMember::SyncMembersTest < ActiveSupport::TestCase
  test "adds new members" do
    team_members = { 'ruby' => %w[ErikSchierboom iHiD], 'fsharp' => %w[ErikSchierboom DJ] }
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    Github::TeamMember::SyncMembers.()

    assert ::Github::TeamMember.where(team: 'ruby', username: 'ErikSchierboom').exists?
    assert ::Github::TeamMember.where(team: 'ruby', username: 'iHiD').exists?
    assert ::Github::TeamMember.where(team: 'fsharp', username: 'ErikSchierboom').exists?
    assert ::Github::TeamMember.where(team: 'fsharp', username: 'DJ').exists?
  end

  test "keeps existing members" do
    team_members = { 'ruby' => ['ErikSchierboom'] }
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    create :github_team_member, team: 'ruby', username: 'ErikSchierboom'

    Github::TeamMember::SyncMembers.()

    assert_equal 1, ::Github::TeamMember.count
    assert ::Github::TeamMember.where(team: 'ruby', username: 'ErikSchierboom').exists?
  end

  test "removes former members" do
    team_members = { 'ruby' => ['iHiD'], 'fsharp' => ['ErikSchierboom'] }
    Github::Organization.any_instance.stubs(:team_members).returns(team_members)

    create :github_team_member, team: 'ruby', username: 'DJ'

    Github::TeamMember::SyncMembers.()

    assert_equal 2, ::Github::TeamMember.count
    refute ::Github::TeamMember.where(team: 'ruby', username: 'DJ').exists?
    assert ::Github::TeamMember.where(team: 'ruby', username: 'iHiD').exists?
    assert ::Github::TeamMember.where(team: 'fsharp', username: 'ErikSchierboom').exists?
  end
end
