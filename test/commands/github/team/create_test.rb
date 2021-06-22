require "test_helper"

class Github::Team::CreateTest < ActiveSupport::TestCase
  test "create team" do
    Exercism.config.stubs(:github_organization).returns('exercism')

    stub_request(:post, "https://api.github.com/orgs/exercism/teams").
      with(
        body: {
          name: "C# maintainers",
          repo_names: ["exercism/csharp"],
          privacy: :closed,
          parent_team_id: nil
        }.to_json
      ).
      to_return(
        status: 200,
        body: { name: "reviewers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    Github::Team::Create.("C# maintainers", "csharp")
  end
end
