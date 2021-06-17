require "test_helper"

class Github::OrganizationMember::RemoveTest < ActiveSupport::TestCase
  test "removes member" do
    user = create :user, github_username: 'my-handle'

    stub_request(:delete, "https://api.github.com/orgs/exercism/members/my-handle").
      to_return(status: 200, body: "", headers: {})

    Github::OrganizationMember::Remove.(user.github_username)
  end
end
