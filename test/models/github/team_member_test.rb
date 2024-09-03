require "test_helper"

class Github::TeamMemberTest < ActiveSupport::TestCase
  test "user" do
    user = create(:user, uid: SecureRandom.uuid)
    team_member = create(:github_team_member, user:)

    assert_equal user, team_member.user
    assert_includes user.github_team_memberships, team_member
  end

  test "team track" do
    user = create(:user, uid: SecureRandom.uuid)
    track = create :track
    team_member = create(:github_team_member, user:, team_name: track.github_team_name)

    assert_equal track, team_member.track
  end

  test "non-team track" do
    user = create(:user, uid: SecureRandom.uuid)
    team_member = create(:github_team_member, user:)

    assert_nil team_member.track
  end
end
