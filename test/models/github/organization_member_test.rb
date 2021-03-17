require "test_helper"

class Github::OrganizationMemberTest < ActiveSupport::TestCase
  test "creates github organization member" do
    member = create :github_organization_member, username: 'iHiD'

    assert_equal 'iHiD', member.username
  end
end
