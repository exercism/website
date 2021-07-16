require "test_helper"

class ContributorTeam::MembershipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    team = create :contributor_team
    user = create :user
    membership = create :contributor_team_membership,
      team: team,
      user: user

    assert_equal team, membership.team
    assert_equal user, membership.user
  end
end
