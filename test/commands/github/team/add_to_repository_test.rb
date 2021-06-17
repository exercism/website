require "test_helper"

class Github::Team::AddToRepositoryTest < ActiveSupport::TestCase
  test "add member" do
    stub_request(:get, "https://api.github.com/orgs/exercism/teams/reviewers").
      to_return(
        status: 200,
        body: { name: "reviewers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:put, "https://api.github.com/teams/3076122/repos/exercism/csharp").
      to_return(status: 200, body: "", headers: {})

    Github::Team::AddToRepository.('reviewers', 'exercism/csharp')
  end
end
