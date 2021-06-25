require "test_helper"

class Github::OrganizationMember::RemoveWhenNoTeamMembershipsTest < ActiveSupport::TestCase
  test "removes user from organization if user is not a member of any team" do
    Github::Organization.any_instance.stubs(:team_memberships_count).with('user22').returns(0)
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    stub_request(:delete, "https://api.github.com/orgs/exercism/members/user22").
      to_return(status: 200, body: "", headers: {})

    Github::OrganizationMember::RemoveWhenNoTeamMemberships.('user22')
  end

  test "does not remove user from organization if user is a member of at least one team" do
    Github::Organization.any_instance.stubs(:team_memberships_count).with('user22').returns(1)

    Exercism.octokit_client.stubs(:remove_organization_membership).never

    Github::OrganizationMember::RemoveWhenNoTeamMemberships.('user22')
  end
end
