require "test_helper"

class Github::Repository::UpdateSettingsTest < ActiveSupport::TestCase
  test "updates branch protections of track and track tooling repos" do
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

    Github::Repository::UpdateTeams.stubs(:call)
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

  test "updates teams for track and track tooling repos" do
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

    Github::Repository::UpdateBranchProtection.stubs(:call)
    Github::Repository::UpdateTeams.expects(:call).with(
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
