require "test_helper"

class Github::Team::CreateTest < ActiveSupport::TestCase
  test "create team" do
    stub_request(:post, "https://api.github.com/orgs/exercism/teams").
      with(
        body: { name: "C# maintainers", repo_names: ["exercism/csharp"] }.to_json
      ).
      to_return(
        status: 200,
        body: { name: "reviewers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    Github::Team::Create.("C# maintainers", "exercism/csharp")
  end
end
