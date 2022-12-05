require "test_helper"

class Github::TeamMember::CreateTest < ActiveSupport::TestCase
  test "creates team member" do
    username = 'yoshiro'
    team = 'fsharp'

    team_member = Github::TeamMember::Create.(username, team)

    assert_equal username, team_member.username
    assert_equal team, team_member.team
  end

  test "idempotent" do
    assert_idempotent_command do
      Github::TeamMember::Create.('yoshiro', 'fsharp')
    end

    assert_equal 1, Github::TeamMember.count
  end
end
