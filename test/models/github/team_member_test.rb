require "test_helper"

class Github::TeamMemberTest < ActiveSupport::TestCase
  test "user" do
    user = create(:user, uid: SecureRandom.uuid)
    team_member = create(:github_team_member, user:)

    assert_equal user, team_member.user
    assert_includes user.github_team_memberships, team_member
  end
end
