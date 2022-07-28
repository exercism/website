require "test_helper"

class Github::Repository::UpdateMaintainersAdminTeamPermissionsTest < ActiveSupport::TestCase
  test "adds @maintainers team to all repos, regardless if track is active or not" do
    create :track, slug: 'elixir', active: true
    create :track, slug: 'nim', active: false

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/maintainers-admin").
      to_return(
        status: 200,
        body: { id: 555 }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    repos = [
      Github::Repository.new('elixir', :track),
      Github::Repository.new('elixir-test-runner', :tooling),
      Github::Repository.new('nim', :track),
      Github::Repository.new('nim-analyzer', :tooling),
      Github::Repository.new('nim-representer', :tooling)
    ]

    repos.each do |repo|
      stub_request(:put, "https://api.github.com/teams/555/repos/#{repo.name_with_owner}").
        with(body: { permission: :maintain }.to_json).
        to_return(status: 200, body: "", headers: {})
    end

    Github::Repository::UpdateMaintainersAdminTeamPermissions.(repos)
  end
end
