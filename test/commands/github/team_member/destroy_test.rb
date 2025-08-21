require "test_helper"

class Github::TeamMember::DestroyTest < ActiveSupport::TestCase
  test "removes team member" do
    github_uid = '137131'
    team_name = 'fsharp'

    user = create(:user, uid: github_uid)
    team_member = create(:github_team_member, team_name:, user:)

    Github::TeamMember::Destroy.(team_member)

    refute Github::TeamMember.where(user:, team_name:).exists?
  end

  test "update maintainer role when track team" do
    github_uid = '137131'
    team_name = 'fsharp'

    user = create(:user, uid: github_uid)
    create(:track, slug: team_name)
    team_member = create(:github_team_member, team_name:, user:)

    User::UpdateMaintainer.expects(:call).with(user).once

    Github::TeamMember::Destroy.(team_member)
  end

  test "don't update maintainer role when not track team" do
    github_uid = '137131'
    team_name = 'configlet'

    user = create(:user, uid: github_uid)
    team_member = create(:github_team_member, team_name:, user:)

    User::UpdateMaintainer.expects(:call).never

    Github::TeamMember::Destroy.(team_member)
  end

  test "idempotent" do
    github_uid = '137131'
    team_name = 'fsharp'

    user = create(:user, uid: github_uid)
    team_member = create(:github_team_member, team_name:, user:)

    assert_idempotent_command do
      Github::TeamMember::Destroy.(team_member)
    end

    refute Github::TeamMember.where(user:, team_name:).exists?
  end
end
