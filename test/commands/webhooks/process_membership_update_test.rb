require "test_helper"

class Webhooks::ProcessMembershipUpdateTest < ActiveSupport::TestCase
  %w[added removed].each do |action|
    test "adds membership if action is #{action} and organization is exercism" do
      user = create :user, github_username: 'user22'
      team = create :contributor_team, github_name: 'team11'
      Github::Team.any_instance.expects(:add_member).with('user22')

      Webhooks::ProcessMembershipUpdate.(action, 'user22', 'team11', 'exercism')

      assert ContributorTeam::Membership.where(user: user, team: team).exists?
    end

    test "does not add membership if action is #{action} and organization is not exercism" do
      create :user, github_username: 'user22'
      create :contributor_team, github_name: 'team11'

      Webhooks::ProcessMembershipUpdate.(action, 'user22', 'team11', 'other-org')

      assert_equal 0, ContributorTeam::Membership.find_each.size
    end

    test "does not add membership if action is #{action} and user cannot be found" do
      create :user, github_username: 'user22'
      create :contributor_team, github_name: 'team11'

      Webhooks::ProcessMembershipUpdate.(action, 'unknown-user', 'team11', 'exercism')

      assert_equal 0, ContributorTeam::Membership.find_each.size
    end

    test "does not add membership if action is #{action} and team cannot be found" do
      create :user, github_username: 'user22'
      create :contributor_team, github_name: 'team11'

      Webhooks::ProcessMembershipUpdate.(action, 'user22', 'unknown-team', 'exercism')

      assert_equal 0, ContributorTeam::Membership.find_each.size
    end
  end

  test "does not add membership if action is not supported" do
    create :user, github_username: 'user22'
    create :contributor_team, github_name: 'team11'

    Webhooks::ProcessMembershipUpdate.('other-action', 'user22', 'team11', 'exercism')

    assert_equal 0, ContributorTeam::Membership.find_each.size
  end
end
