require "test_helper"

class Webhooks::ProcessMembershipUpdateTest < ActiveSupport::TestCase
  %w[added removed].each do |action|
    test "updates reviewer permission if action is #{action} and TEAM can be found" do
      Github::Organization.any_instance.stubs(:name).returns('exercism')

      create :user, github_username: 'user22'
      team = create :contributor_team, github_name: 'team11'
      Github::OrganizationMember::RemoveWhenNoTeamMemberships.stubs(:call)

      ContributorTeam::UpdateReviewersPermission.expects(:call).with(team)

      Webhooks::ProcessMembershipUpdate.(action, 'user22', 'team11', 'exercism')
    end

    test "does not update reviewer permission if action is #{action} and TEAM cannot be found" do
      Github::Organization.any_instance.stubs(:name).returns('exercism')

      create :user, github_username: 'user22'
      create :contributor_team, github_name: 'team11'
      Github::OrganizationMember::RemoveWhenNoTeamMemberships.stubs(:call)

      ContributorTeam::UpdateReviewersPermission.expects(:call).never

      Webhooks::ProcessMembershipUpdate.(action, 'user22', 'unknown-team', 'exercism')
    end

    test "checks org membership if action is #{action} and user can be found" do
      Github::Organization.any_instance.stubs(:name).returns('exercism')

      user = create :user, github_username: 'user22'
      create :contributor_team, github_name: 'team11'
      ContributorTeam::UpdateReviewersPermission.stubs(:call)

      Github::OrganizationMember::RemoveWhenNoTeamMemberships.expects(:call).with(user.github_username)

      Webhooks::ProcessMembershipUpdate.(action, 'user22', 'team11', 'exercism')
    end

    test "does not check org membership if action is #{action} and user cannot be found" do
      Github::Organization.any_instance.stubs(:name).returns('exercism')

      create :user, github_username: 'user22'
      create :contributor_team, github_name: 'team11'
      ContributorTeam::UpdateReviewersPermission.stubs(:call)

      Github::OrganizationMember::RemoveWhenNoTeamMemberships.expects(:call).never

      Webhooks::ProcessMembershipUpdate.(action, 'unknown-user', 'team11', 'exercism')
    end
  end

  test "does not do anything if organization does not match" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    create :user, github_username: 'user22'
    create :contributor_team, github_name: 'team11'

    Github::OrganizationMember::RemoveWhenNoTeamMemberships.expects(:call).never
    ContributorTeam::UpdateReviewersPermission.expects(:call).never

    Webhooks::ProcessMembershipUpdate.('add', 'user22', 'team11', 'invalid-org')
  end

  test "does not do anything if action is unknown" do
    create :user, github_username: 'user22'
    create :contributor_team, github_name: 'team11'

    Github::OrganizationMember::RemoveWhenNoTeamMemberships.expects(:call).never
    ContributorTeam::UpdateReviewersPermission.expects(:call).never

    Webhooks::ProcessMembershipUpdate.('invalid-action', 'user22', 'team11', 'exercism')
  end
end
