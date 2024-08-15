require "test_helper"

class Github::TeamMember::DestroyTest < ActiveSupport::TestCase
  test "removes team member" do
    github_uid = '137131'
    team_name = 'fsharp'

    user = create(:user, uid: github_uid)
    create(:github_team_member, team_name:, user:)

    # Sanity check
    assert Github::TeamMember.where(user:, team_name:).exists?

    Github::TeamMember::Destroy.(github_uid, team_name)

    refute Github::TeamMember.where(user:, team_name:).exists?
  end

  test "update maintainer role" do
    github_uid = '137131'
    team_name = 'fsharp'

    user = create(:user, uid: github_uid)
    create(:github_team_member, team_name:, user:)

    User::UpdateMaintainer.expects(:call).with(user).once

    Github::TeamMember::Destroy.(github_uid, team_name)
  end

  test "idempotent" do
    github_uid = '137131'
    team_name = 'fsharp'

    user = create(:user, uid: github_uid)

    assert_idempotent_command do
      Github::TeamMember::Destroy.(github_uid, team_name)
    end

    refute Github::TeamMember.where(user:, team_name:).exists?
  end
end
