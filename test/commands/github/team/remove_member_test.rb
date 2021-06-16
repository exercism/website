require "test_helper"

class Github::Team::RemoveMemberTest < ActiveSupport::TestCase
  test "removes member" do
    stub_request(:get, "https://api.github.com/orgs/exercism/teams/csharp-maintainers").
      to_return(
        status: 200,
        body: { name: "alumni", id: 2_022_925 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:delete, "https://api.github.com/teams/2022925/memberships/ErikSchierboom").
      to_return(status: 200, body: "", headers: {})

    Github::Team::RemoveMember.('csharp-maintainers', 'ErikSchierboom')
  end
end
