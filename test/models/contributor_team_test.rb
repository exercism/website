require "test_helper"

class ContributorTeamTest < ActiveSupport::TestCase
  test "wired in correctly" do
    track = create :track
    team = create :contributor_team, track: track

    assert_equal track, team.track
  end

  test "members" do
    team = create :contributor_team
    user_1 = create :user
    user_2 = create :user
    create :contributor_team_membership, team: team, user: user_1
    create :contributor_team_membership, team: team, user: user_2

    assert_equal [user_1, user_2], team.members
  end

  test "role_for_members for track_maintainers" do
    team = create :contributor_team, type: :track_maintainers, track: (create :track)

    assert_equal :maintainer, team.role_for_members
  end

  test "role_for_members for project_maintainers" do
    team = create :contributor_team, type: :project_maintainers, track: nil

    assert_equal :maintainer, team.role_for_members
  end

  test "role_for_members for reviewers" do
    team = create :contributor_team, type: :reviewers, track: nil

    assert_equal :reviewer, team.role_for_members
  end
end
