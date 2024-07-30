require "test_helper"

class Github::TeamMemberTest < ActiveSupport::TestCase
  test "user" do
    uid = "123"
    team_name = "ruby"
    user = create(:user, uid:)

    team_member = create(:github_team_member, user_id: uid, team_name:)
    assert_equal user, team_member.user
    assert_includes user.github_team_memberships, team_member
  end
end
