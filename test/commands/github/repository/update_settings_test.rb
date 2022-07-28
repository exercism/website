require "test_helper"

class Github::Repository::UpdateSettingsTest < ActiveSupport::TestCase
  def setup
    stub_request(:get, "https://api.github.com/search/repositories?per_page=100&q=org:exercism%20topic:exercism-track").
      to_return(
        status: 200,
        body: { items: [{ name: "elixir" }, { name: "nim" }] }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, "https://api.github.com/search/repositories?per_page=100&q=org:exercism%20topic:exercism-tooling").
      to_return(
        status: 200,
        body: { items: [{ name: "elixir-test-runner" }, { name: "nim-analyzer" }, { name: "nim-representer" }] }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
  end

  test "updates branch protections of track and track tooling repos" do
    Github::Repository::UpdateMaintainersAdminTeamPermissions.stubs(:call)
    Github::Repository::UpdateReviewersTeamPermissions.stubs(:call)

    Github::Repository::UpdateBranchProtection.expects(:call).with(
      [
        Github::Repository.new('elixir', :track),
        Github::Repository.new('elixir-test-runner', :tooling),
        Github::Repository.new('nim', :track),
        Github::Repository.new('nim-analyzer', :tooling),
        Github::Repository.new('nim-representer', :tooling)
      ]
    )

    Github::Repository::UpdateSettings.()
  end

  test "updates @maintainers-admin team permissions for track and track tooling repos" do
    Github::Repository::UpdateBranchProtection.stubs(:call)
    Github::Repository::UpdateReviewersTeamPermissions.stubs(:call)

    Github::Repository::UpdateMaintainersAdminTeamPermissions.expects(:call).with(
      [
        Github::Repository.new('elixir', :track),
        Github::Repository.new('elixir-test-runner', :tooling),
        Github::Repository.new('nim', :track),
        Github::Repository.new('nim-analyzer', :tooling),
        Github::Repository.new('nim-representer', :tooling)
      ]
    )

    Github::Repository::UpdateSettings.()
  end

  test "updates @reviewers team permissions for track and track tooling repos" do
    Github::Repository::UpdateBranchProtection.stubs(:call)
    Github::Repository::UpdateMaintainersAdminTeamPermissions.stubs(:call)

    Github::Repository::UpdateReviewersTeamPermissions.expects(:call).with(
      [
        Github::Repository.new('elixir', :track),
        Github::Repository.new('elixir-test-runner', :tooling),
        Github::Repository.new('nim', :track),
        Github::Repository.new('nim-analyzer', :tooling),
        Github::Repository.new('nim-representer', :tooling)
      ]
    )

    Github::Repository::UpdateSettings.()
  end
end
