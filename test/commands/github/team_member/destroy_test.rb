require "test_helper"

class Github::TeamMember::DestroyTest < ActiveSupport::TestCase
  test "removes team member" do
    username = 'yoshiro'
    team = 'fsharp'

    create :github_team_member, team: team, username: username

    # Sanity check
    assert Github::TeamMember.exists?

    Github::TeamMember::Destroy.(username, team)

    refute Github::TeamMember.exists?
  end

  test "idempotent" do
    assert_idempotent_command do
      Github::TeamMember::Destroy.('yoshiro', 'fsharp')
    end

    refute Github::TeamMember.exists?
  end
end
