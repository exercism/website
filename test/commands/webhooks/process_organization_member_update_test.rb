require "test_helper"

class Webhooks::ProcessOrganizationMemberUpdateTest < ActiveSupport::TestCase
  test "adds member if action is 'member_added' and organization is exercism" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    Webhooks::ProcessOrganizationMemberUpdate.('member_added', 'user22', 'exercism')

    member = Github::OrganizationMember.find_by(username: 'user22')
    refute member.alumnus
  end

  test "sets alumnus to false for member if member already exists and action is 'member_added' and organization is exercism" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    member = create :github_organization_member, username: 'user22', alumnus: true

    Webhooks::ProcessOrganizationMemberUpdate.('member_added', 'user22', 'exercism')

    refute member.reload.alumnus
  end

  test "does not add member if action is 'member_added' and organization is not exercism" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    Webhooks::ProcessOrganizationMemberUpdate.('member_added', 'user22', 'other-org')

    refute Github::OrganizationMember.where(username: 'user22').exists?
  end

  test "does not add member if action is not 'member_added'" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    Webhooks::ProcessOrganizationMemberUpdate.('other-action', 'user22', 'exercism')

    refute Github::OrganizationMember.where(username: 'user22').exists?
  end

  test "makes member alumnus if action is 'member_removed' and organization is exercism" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    create :github_organization_member, username: 'user22'

    Webhooks::ProcessOrganizationMemberUpdate.('member_removed', 'user22', 'exercism')

    member = Github::OrganizationMember.find_by(username: 'user22')
    assert member.alumnus
  end

  test "does not makes member alumnus if action is 'member_removed' and organization is not exercism" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    create :github_organization_member, username: 'user22'

    Webhooks::ProcessOrganizationMemberUpdate.('member_added', 'user22', 'other-org')

    member = Github::OrganizationMember.find_by(username: 'user22')
    refute member.alumnus
  end

  test "does not remove member if action is not 'member_removed'" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    create :github_organization_member, username: 'user22'

    Webhooks::ProcessOrganizationMemberUpdate.('other-action', 'user22', 'exercism')

    assert Github::OrganizationMember.where(username: 'user22').exists?
  end
end
