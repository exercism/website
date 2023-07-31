require "test_helper"

class Github::TeamMember::DestroyTest < ActiveSupport::TestCase
  test "removes team member" do
    user_id = '137131'
    team_name = 'fsharp'

    create(:github_team_member, team_name:, user_id:)

    # Sanity check
    assert Github::TeamMember.where(user_id:, team_name:).exists?

    Github::TeamMember::Destroy.(user_id, team_name)

    refute Github::TeamMember.where(user_id:, team_name:).exists?
  end

  test "idempotent" do
    user_id = '137131'
    team_name = 'fsharp'

    assert_idempotent_command do
      Github::TeamMember::Destroy.(user_id, team_name)
    end

    refute Github::TeamMember.where(user_id:, team_name:).exists?
  end
end
