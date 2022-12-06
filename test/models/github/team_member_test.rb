require "test_helper"

class Github::TeamMemberTest < ActiveSupport::TestCase
  test "user" do
    team_member = create :github_team_member
    assert_nil team_member.user

    user = create :user, uid: team_member.user_id
    assert_equal user, team_member.reload.user
  end
end
