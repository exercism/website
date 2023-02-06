require "test_helper"

class Github::TeamMember::CreateTest < ActiveSupport::TestCase
  test "creates team member" do
    user_id = '137131'
    team_name = 'fsharp'

    team_name_member = Github::TeamMember::Create.(user_id, team_name)

    assert_equal 1, Github::TeamMember.count
    assert_equal user_id, team_name_member.user_id
    assert_equal team_name, team_name_member.team_name
  end

  test "idempotent" do
    user_id = '137131'
    team_name = 'fsharp'

    assert_idempotent_command do
      Github::TeamMember::Create.(user_id, team_name)
    end

    assert_equal 1, Github::TeamMember.count
    assert Github::TeamMember.where(user_id:, team_name:).exists?
  end
end
