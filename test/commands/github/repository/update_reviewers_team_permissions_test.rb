require "test_helper"

class Github::Repository::UpdateReviewersTeamPermissionsTest < ActiveSupport::TestCase
  test "adds @reviewers team to active repos with one or zero track team members" do
    create :track, slug: 'elixir', active: true
    create :track, slug: 'nim', active: true
    create :track, slug: 'fsharp', active: true
    create :track, slug: 'csharp', active: false
    create :track, slug: 'gleam', active: false
    create :track, slug: 'unison', active: false

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/reviewers").
      to_return(
        status: 200,
        body: { id: 333 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://api.github.com/graphql").
      with(
        body: "{\"query\":\"query ($endCursor: String) {\\n  organization(login: \\\"exercism\\\") {\\n    team(slug: \\\"track-maintainers\\\") {\\n      childTeams(first: 50, after: $endCursor) {\\n        totalCount\\n        nodes {\\n          name\\n          members(first: 100) {\\n            totalCount\\n          }\\n        }\\n        pageInfo {\\n          endCursor\\n        }\\n      }\\n    }\\n  }\\n}  \\n\",\"variables\":\"{\\\"endCursor\\\":null}\"}" # rubocop:disable Layout/LineLength
      ).
      to_return(
        status: 200,
        body: {
          data: {
            organization: {
              team: {
                childTeams: {
                  nodes: [
                    { name: "elixir", members: { totalCount: 3 } }, # Active track
                    { name: "nim", members: { totalCount: 1 } },    # Active track
                    { name: "fsharp", members: { totalCount: 0 } }, # Active track
                    { name: "csharp", members: { totalCount: 2 } }, # Inactive track
                    { name: "unison", members: { totalCount: 1 } }, # Inactive track
                    { name: "gleam", members: { totalCount: 0 } }   # Inactive track
                  ]
                }
              }
            }
          }
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    repos = [
      Github::Repository.new('elixir', :track),
      Github::Repository.new('elixir-test-runner', :tooling),
      Github::Repository.new('nim', :track),
      Github::Repository.new('nim-analyzer', :tooling),
      Github::Repository.new('nim-representer', :tooling),
      Github::Repository.new('fsharp', :track),
      Github::Repository.new('csharp', :track),
      Github::Repository.new('csharp-test-runner', :tooling),
      Github::Repository.new('gleam', :track),
      Github::Repository.new('unison', :track),
      Github::Repository.new('unison-representer', :tooling)
    ]

    # Verify that the reviewers team is only added to repos of
    # active and inactive tracks with few maintainers
    %w[nim nim-analyzer nim-representer fsharp gleam unison unison-representer].each do |repo|
      stub_request(:put, "https://api.github.com/teams/333/repos/exercism/#{repo}").
        with(body: { permission: :push }.to_json).
        to_return(status: 200, body: "", headers: {})
    end

    Github::Repository::UpdateReviewersTeamPermissions.(repos)
  end
end
