require "test_helper"

class Github::TeamMember::DestroyTest < ActiveSupport::TestCase
  test "removes team member" do
    user_id = 137_131
    team = 'fsharp'

    create :github_team_member, team: team, user_id: user_id

    # Sanity check
    assert Github::TeamMember.exists?

    Github::TeamMember::Destroy.(user_id, team)

    refute Github::TeamMember.exists?
  end

  test "idempotent" do
    assert_idempotent_command do
      Github::TeamMember::Destroy.(137_131, 'fsharp')
    end

    refute Github::TeamMember.exists?
  end
end
