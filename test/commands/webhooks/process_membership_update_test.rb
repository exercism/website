require "test_helper"

class Webhooks::ProcessMembershipUpdateTest < ActiveSupport::TestCase
  %w[added removed].each do |action|
    test "updates reviewer permission if action is #{action}" do
      create :user, github_username: 'user22'
      team = create :contributor_team, github_name: 'team11'
      ContributorTeam::CheckOrgMembership.stubs(:call)

      ContributorTeam::UpdateReviewersPermission.expects(:call).with(team)

      Webhooks::ProcessMembershipUpdate.(action, 'user22', 'team11', 'exercism')
    end

    test "checks org membership if action is #{action}" do
      user = create :user, github_username: 'user22'
      create :contributor_team, github_name: 'team11'
      ContributorTeam::UpdateReviewersPermission.stubs(:call)

      ContributorTeam::CheckOrgMembership.expects(:call).with(user)

      Webhooks::ProcessMembershipUpdate.(action, 'user22', 'team11', 'exercism')
    end

    test "does not do anything if action is #{action} and user is not found" do
      create :user, github_username: 'user22'
      create :contributor_team, github_name: 'team11'

      ContributorTeam::CheckOrgMembership.expects(:call).never
      ContributorTeam::UpdateReviewersPermission.expects(:call).never

      Webhooks::ProcessMembershipUpdate.(action, 'unknown-user', 'team11', 'exercism')
    end

    test "does not do anything if action is #{action} and team is not found" do
      create :user, github_username: 'user22'
      create :contributor_team, github_name: 'team11'

      ContributorTeam::CheckOrgMembership.expects(:call).never
      ContributorTeam::UpdateReviewersPermission.expects(:call).never

      Webhooks::ProcessMembershipUpdate.(action, 'user22', 'unknown-team', 'exercism')
    end
  end

  test "does not do anything if action is unknown" do
    create :user, github_username: 'user22'
    create :contributor_team, github_name: 'team11'

    ContributorTeam::CheckOrgMembership.expects(:call).never
    ContributorTeam::UpdateReviewersPermission.expects(:call).never

    Webhooks::ProcessMembershipUpdate.('invalid-action', 'user22', 'team11', 'exercism')
  end
end
