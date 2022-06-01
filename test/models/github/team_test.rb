require "test_helper"

class Github::TeamTest < ActiveSupport::TestCase
  test "add_membership" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/csharp-maintainers").
      to_return(
        status: 200,
        body: { name: "alumni", id: 2_022_925 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:put, "https://api.github.com/teams/2022925/memberships/ErikSchierboom").
      to_return(status: 200, body: "", headers: {})

    team = Github::Team.new('csharp-maintainers')

    team.add_membership('ErikSchierboom')
  end

  test "remove_membership" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/csharp-maintainers").
      to_return(
        status: 200,
        body: { name: "alumni", id: 2_022_925 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:delete, "https://api.github.com/teams/2022925/memberships/ErikSchierboom").
      to_return(status: 200, body: "", headers: {})

    team = Github::Team.new('csharp-maintainers')

    team.remove_membership('ErikSchierboom')
  end

  test "add_to_repository" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/reviewers").
      to_return(
        status: 200,
        body: { name: "reviewers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:put, "https://api.github.com/teams/3076122/repos/exercism/csharp").
      with(body: { permission: "push" }.to_json).
      to_return(status: 200, body: "", headers: {})

    team = Github::Team.new('reviewers')

    team.add_to_repository('exercism/csharp', :push)
  end

  test "remove_from_repository" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/reviewers").
      to_return(
        status: 200,
        body: { name: "reviewers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:delete, "https://api.github.com/teams/3076122/repos/exercism/csharp").
      to_return(status: 200, body: "", headers: {})

    team = Github::Team.new('reviewers')

    team.remove_from_repository('exercism/csharp')
  end

  test "repositories" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/reviewers").
      to_return(
        status: 200,
        body: { name: "reviewers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, "https://api.github.com/teams/3076122/repos?per_page=100").
      to_return(
        status: 200,
        body: [
          { full_name: "exercism/csharp" },
          { full_name: "exercism/ruby" }
        ].to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    team = Github::Team.new('reviewers')

    repositories = team.repositories

    assert_equal 2, repositories.size
    assert_equal ['exercism/csharp', 'exercism/ruby'], repositories.pluck(:full_name)
  end

  test "create without parent team" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    stub_request(:post, "https://api.github.com/orgs/exercism/teams").
      with(
        body: {
          name: "csharp-maintainers",
          repo_names: ["exercism/csharp"],
          privacy: :closed,
          parent_team_id: nil
        }.to_json,
        headers: {
          accept: 'application/vnd.github.hellcat-preview+json'
        }
      ).
      to_return(
        status: 200,
        body: { name: "reviewers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    team = Github::Team.new('csharp-maintainers')

    team.create('csharp')
  end

  test "create with parent team" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/track-maintainers").
      to_return(
        status: 200,
        body: { name: "track-maintainers", id: 2_022_925 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://api.github.com/orgs/exercism/teams").
      with(
        body: {
          name: "csharp-maintainers",
          repo_names: ["exercism/csharp"],
          privacy: :closed,
          parent_team_id: 2_022_925
        }.to_json
      ).
      to_return(
        status: 200,
        body: { name: "csharp-maintainers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    parent_team = Github::Team.new('track-maintainers')
    team = Github::Team.new('csharp-maintainers')

    team.create('csharp', parent_team:)
  end
end
