require "test_helper"

class Github::OrganizationMember::RemoveWhenNoTeamMembershipsTest < ActiveSupport::TestCase
  test "removes user from organization if user is not a member of any team" do
    Github::Organization.any_instance.stubs(:team_membership_count_for_user).with('user22').returns(0)
    Github::Organization.any_instance.stubs(:remove_member).with('user22')

    Github::OrganizationMember::RemoveWhenNoTeamMemberships.('user22')
  end

  test "does not remove user from organization if user is a member of at least one team" do
    Github::Organization.any_instance.stubs(:team_membership_count_for_user).with('user22').returns(1)
    Github::Organization.any_instance.stubs(:remove_member).never

    Github::OrganizationMember::RemoveWhenNoTeamMemberships.('user22')
  end
end
