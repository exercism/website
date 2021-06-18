require "test_helper"

class Github::TeamTest < ActiveSupport::TestCase
  test "create team" do
    Exercism.config.stubs(:github_organization).returns('exercism')

    stub_request(:post, "https://api.github.com/orgs/exercism/teams").
      with(
        body: { name: "csharp-maintainers", repo_names: ["exercism/csharp"] }.to_json
      ).
      to_return(
        status: 200,
        body: { name: "reviewers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    team = Github::Team.new('csharp-maintainers')

    team.create('exercism/csharp')
  end

  test "add member" do
    Exercism.config.stubs(:github_organization).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/csharp-maintainers").
      to_return(
        status: 200,
        body: { name: "alumni", id: 2_022_925 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:put, "https://api.github.com/teams/2022925/memberships/ErikSchierboom").
      to_return(status: 200, body: "", headers: {})

    team = Github::Team.new('csharp-maintainers')

    team.add_member('ErikSchierboom')
  end

  test "remove_member" do
    Exercism.config.stubs(:github_organization).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/csharp-maintainers").
      to_return(
        status: 200,
        body: { name: "alumni", id: 2_022_925 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:delete, "https://api.github.com/teams/2022925/memberships/ErikSchierboom").
      to_return(status: 200, body: "", headers: {})

    team = Github::Team.new('csharp-maintainers')

    team.remove_member('ErikSchierboom')
  end

  test "add_to_repository" do
    Exercism.config.stubs(:github_organization).returns('exercism')

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
    Exercism.config.stubs(:github_organization).returns('exercism')

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

  test "members" do
    Exercism.config.stubs(:github_organization).returns('exercism')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/reviewers").
      to_return(
        status: 200,
        body: { name: "reviewers", id: 3_076_122 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, "https://api.github.com/teams/3076122/members?per_page=100").
      to_return(
        status: 200,
        body: [
          { login: 'member-one',   id: 1 },
          { login: 'member-two',   id: 2 },
          { login: 'member-three', id: 3 }
        ].to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    team = Github::Team.new('reviewers')

    assert_equal 3, team.members.size
    assert_equal %w[member-one member-two member-three], team.members.pluck(:login)
    assert_equal [1, 2, 3], team.members.pluck(:id)
  end
end
