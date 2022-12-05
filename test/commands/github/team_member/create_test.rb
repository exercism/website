require "test_helper"

class Github::TeamMember::CreateTest < ActiveSupport::TestCase
  test "creates team member" do
    user_id = 137_131
    team = 'fsharp'

    team_member = Github::TeamMember::Create.(user_id, team)

    assert_equal user_id, team_member.user_id
    assert_equal team, team_member.team
  end

  test "idempotent" do
    assert_idempotent_command do
      Github::TeamMember::Create.(137_131, 'fsharp')
    end

    assert_equal 1, Github::TeamMember.count
  end
end
