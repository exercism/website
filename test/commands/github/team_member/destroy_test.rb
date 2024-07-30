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

  test "does not remove user" do
    user_id = '137131'
    team_name = 'fsharp'

    user = create(:user, uid: user_id)
    create(:github_team_member, team_name:, user_id:)

    # Sanity check
    assert Github::TeamMember.where(user_id:, team_name:).exists?

    Github::TeamMember::Destroy.(user_id, team_name)

    refute Github::TeamMember.where(user_id:, team_name:).exists?
    assert User.where(id: user.id).exists?
  end

  test "update maintainer role" do
    user_id = '137131'
    team_name = 'fsharp'

    create(:github_team_member, team_name:, user_id:)

    user = create(:user, uid: user_id)
    User::UpdateMaintainer.expects(:call).with(user).once

    Github::TeamMember::Destroy.(user_id, team_name)
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
