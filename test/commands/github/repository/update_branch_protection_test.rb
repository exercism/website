require "test_helper"

class Github::Repository::UpdateBranchProtectionTest < ActiveSupport::TestCase
  test "sets correct branch protection for active track's repo" do
    create :track, slug: 'elixir', active: true

    stub_request(:get, "https://api.github.com/repos/exercism/elixir/branches/main/protection").
      to_return(status: 200, body: current_branch_protection_settings.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://api.github.com/repos/exercism/elixir/branches/main/protection").
      with(body: hash_including({
        required_status_checks: {
          strict: false,
          checks: [{ context: "configlet / configlet", app_id: 15_368 }]
        },
        enforce_admins: false,
        required_pull_request_reviews: {
          dismissal_restrictions: {},
          dismiss_stale_reviews: false,
          require_code_owner_reviews: true,
          required_approving_review_count: 1,
          bypass_pull_request_allowances: { users: [], teams: [] }
        },
        restrictions: nil,
        required_linear_history: false,
        allow_force_pushes: false,
        allow_deletions: false,
        block_creations: false,
        required_conversation_resolution: false
      }), headers: { 'Content-Type': 'application/json' }).
      to_return(status: 200)

    repos = [Github::Repository.new('elixir', :track)]
    Github::Repository::UpdateBranchProtection.(repos)
  end

  test "sets correct branch protection for active track's tooling repo" do
    create :track, slug: 'elixir', active: true

    stub_request(:get, "https://api.github.com/repos/exercism/elixir-representer/branches/main/protection").
      to_return(status: 200, body: current_branch_protection_settings.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://api.github.com/repos/exercism/elixir-representer/branches/main/protection").
      with(body: hash_including({
        required_status_checks: {
          strict: false,
          checks: []
        },
        enforce_admins: false,
        required_pull_request_reviews: {
          dismissal_restrictions: {},
          dismiss_stale_reviews: false,
          require_code_owner_reviews: true,
          required_approving_review_count: 1,
          bypass_pull_request_allowances: { users: [], teams: [] }
        },
        restrictions: nil,
        required_linear_history: false,
        allow_force_pushes: false,
        allow_deletions: false,
        block_creations: false,
        required_conversation_resolution: false
      }), headers: { 'Content-Type': 'application/json' }).
      to_return(status: 200)

    repos = [Github::Repository.new('elixir-representer', :tooling)]
    Github::Repository::UpdateBranchProtection.(repos)
  end

  test "sets correct branch protection for inactive track's repo" do
    create :track, slug: 'gleam', active: false

    stub_request(:get, "https://api.github.com/repos/exercism/gleam/branches/main/protection").
      to_return(status: 200, body: current_branch_protection_settings.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://api.github.com/repos/exercism/gleam/branches/main/protection").
      with(body: hash_including({
        required_status_checks: {
          strict: false,
          checks: [{ context: "configlet / configlet", app_id: 15_368 }]
        },
        enforce_admins: false,
        required_pull_request_reviews: {
          dismissal_restrictions: {},
          dismiss_stale_reviews: false,
          require_code_owner_reviews: true,
          required_approving_review_count: 0,
          bypass_pull_request_allowances: { users: [], teams: [] }
        },
        restrictions: nil,
        required_linear_history: false,
        allow_force_pushes: false,
        allow_deletions: false,
        block_creations: false,
        required_conversation_resolution: false
      }), headers: { 'Content-Type': 'application/json' }).
      to_return(status: 200)

    repos = [Github::Repository.new('gleam', :track)]
    Github::Repository::UpdateBranchProtection.(repos)
  end

  test "sets correct branch protection for inactive track's tooling repo" do
    create :track, slug: 'gleam', active: false

    stub_request(:get, "https://api.github.com/repos/exercism/gleam-representer/branches/main/protection").
      to_return(status: 200, body: current_branch_protection_settings.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://api.github.com/repos/exercism/gleam-representer/branches/main/protection").
      with(body: hash_including({
        required_status_checks: {
          strict: false,
          checks: []
        },
        enforce_admins: false,
        required_pull_request_reviews: {
          dismissal_restrictions: {},
          dismiss_stale_reviews: false,
          require_code_owner_reviews: true,
          required_approving_review_count: 0,
          bypass_pull_request_allowances: { users: [], teams: [] }
        },
        restrictions: nil,
        required_linear_history: false,
        allow_force_pushes: false,
        allow_deletions: false,
        block_creations: false,
        required_conversation_resolution: false
      }), headers: { 'Content-Type': 'application/json' }).
      to_return(status: 200)

    repos = [Github::Repository.new('gleam-representer', :tooling)]
    Github::Repository::UpdateBranchProtection.(repos)
  end

  test "sets required_approving_review_count to 1 for active track's repos if required_approving_review_count is not set" do
    create :track, slug: 'elixir', active: true

    repos = [
      Github::Repository.new('elixir', :track),
      Github::Repository.new('elixir-representer', :tooling)
    ]

    current_settings = current_branch_protection_settings
    current_settings[:required_pull_request_reviews].delete(:required_approving_review_count)

    repos.each do |repo|
      stub_request(:get, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        to_return(status: 200, body: current_settings.to_json, headers: { 'Content-Type': 'application/json' })

      stub_request(:put, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        with do |request|
          json = JSON.parse(request.body)
          json["required_pull_request_reviews"]["required_approving_review_count"] == 1
        end.
        to_return(status: 200)
    end

    Github::Repository::UpdateBranchProtection.(repos)
  end

  test "sets required_approving_review_count to 1 for active track's repos if currently set to 0" do
    create :track, slug: 'elixir', active: true

    repos = [
      Github::Repository.new('elixir', :track),
      Github::Repository.new('elixir-representer', :tooling)
    ]

    current_settings = current_branch_protection_settings
    current_settings[:required_pull_request_reviews][:required_approving_review_count] = 0

    repos.each do |repo|
      stub_request(:get, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        to_return(status: 200, body: current_settings.to_json, headers: { 'Content-Type': 'application/json' })

      stub_request(:put, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        with do |request|
          json = JSON.parse(request.body)
          json["required_pull_request_reviews"]["required_approving_review_count"] == 1
        end.
        to_return(status: 200)
    end

    Github::Repository::UpdateBranchProtection.(repos)
  end

  test "retains current required_approving_review_count for active track's repos if currently set to value greater than 0" do
    create :track, slug: 'elixir', active: true

    repos = [
      Github::Repository.new('elixir', :track),
      Github::Repository.new('elixir-representer', :tooling)
    ]

    [1, 2, 5].each do |required_approving_review_count|
      current_settings = current_branch_protection_settings
      current_settings[:required_pull_request_reviews][:required_approving_review_count] = required_approving_review_count

      repos.each do |repo|
        stub_request(:get, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
          to_return(status: 200, body: current_settings.to_json, headers: { 'Content-Type': 'application/json' })

        stub_request(:put, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
          with do |request|
            json = JSON.parse(request.body)
            json["required_pull_request_reviews"]["required_approving_review_count"] == required_approving_review_count
          end.
          to_return(status: 200)
      end

      Github::Repository::UpdateBranchProtection.(repos)
    end
  end

  test "sets required_approving_review_count to 1 for inactive track's repos if required_approving_review_count is not set" do
    create :track, slug: 'gleam', active: false

    repos = [
      Github::Repository.new('gleam', :track),
      Github::Repository.new('gleam-representer', :tooling)
    ]

    current_settings = current_branch_protection_settings
    current_settings[:required_pull_request_reviews].delete(:required_approving_review_count)

    repos.each do |repo|
      stub_request(:get, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        to_return(status: 200, body: current_settings.to_json, headers: { 'Content-Type': 'application/json' })

      stub_request(:put, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        with do |request|
          json = JSON.parse(request.body)
          json["required_pull_request_reviews"]["required_approving_review_count"].zero?
        end.
        to_return(status: 200)
    end

    Github::Repository::UpdateBranchProtection.(repos)
  end

  test "sets required_approving_review_count to 0 for inactive track's repos if required_approving_review_count is set" do
    create :track, slug: 'gleam', active: false

    repos = [
      Github::Repository.new('gleam', :track),
      Github::Repository.new('gleam-representer', :tooling)
    ]

    [0, 1, 2, 5].each do |required_approving_review_count|
      current_settings = current_branch_protection_settings
      current_settings[:required_pull_request_reviews][:required_approving_review_count] = required_approving_review_count

      repos.each do |repo|
        stub_request(:get, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
          to_return(status: 200, body: current_settings.to_json, headers: { 'Content-Type': 'application/json' })

        stub_request(:put, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
          with do |request|
            json = JSON.parse(request.body)
            json["required_pull_request_reviews"]["required_approving_review_count"].zero?
          end.
          to_return(status: 200)
      end

      Github::Repository::UpdateBranchProtection.(repos)
    end
  end

  test "keeps current required_linear_history value" do
    create :track, slug: 'elixir', active: true
    create :track, slug: 'gleam', active: false

    repos = [
      Github::Repository.new('elixir', :track),
      Github::Repository.new('elixir-analyzer', :tooling),
      Github::Repository.new('gleam', :track),
      Github::Repository.new('gleam-representer', :tooling)
    ]

    [true, false].each do |required_linear_history|
      current_settings = current_branch_protection_settings
      current_settings[:required_linear_history][:enabled] = required_linear_history

      repos.each do |repo|
        stub_request(:get, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
          to_return(status: 200, body: current_settings.to_json, headers: { 'Content-Type': 'application/json' })

        stub_request(:put, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
          with(body: hash_including({ required_linear_history: current_settings[:required_linear_history][:enabled] })).
          to_return(status: 200)
      end

      Github::Repository::UpdateBranchProtection.(repos)
    end
  end

  test "adds configlet check to existing checks for track repos" do
    create :track, slug: 'elixir', active: true
    create :track, slug: 'gleam', active: false

    repos = [
      Github::Repository.new('elixir', :track),
      Github::Repository.new('gleam', :track)
    ]

    current_settings = current_branch_protection_settings
    current_settings[:required_status_checks][:checks] = [{ context: "markdownlint", app_id: 33_555 }]

    repos.each do |repo|
      stub_request(:get, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        to_return(status: 200, body: current_settings.to_json, headers: { 'Content-Type': 'application/json' })

      stub_request(:put, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        with(body: hash_including({
          required_status_checks: {
            strict: false,
            checks: current_settings[:required_status_checks][:checks] + [{ context: "configlet / configlet", app_id: 15_368 }]
          }
        })).
        to_return(status: 200)
    end

    Github::Repository::UpdateBranchProtection.(repos)
  end

  test "adds configlet check for track repos without checks" do
    create :track, slug: 'elixir', active: true
    create :track, slug: 'gleam', active: false

    repos = [
      Github::Repository.new('elixir', :track),
      Github::Repository.new('gleam', :track)
    ]

    current_settings = current_branch_protection_settings
    current_settings[:required_status_checks][:checks] = nil

    repos.each do |repo|
      stub_request(:get, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        to_return(status: 200, body: current_settings.to_json, headers: { 'Content-Type': 'application/json' })

      stub_request(:put, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        with(body: hash_including({
          required_status_checks: {
            strict: false,
            checks: [{ context: "configlet / configlet", app_id: 15_368 }]
          }
        })).
        to_return(status: 200)
    end

    Github::Repository::UpdateBranchProtection.(repos)
  end

  test "keeps current checks for tooling repos" do
    create :track, slug: 'elixir', active: true
    create :track, slug: 'gleam', active: false

    repos = [
      Github::Repository.new('elixir-analyzer', :tooling),
      Github::Repository.new('gleam-representer', :tooling)
    ]

    current_settings = current_branch_protection_settings
    current_settings[:required_status_checks][:checks] = [{ context: "markdownlint", app_id: 33_555 }]

    repos.each do |repo|
      stub_request(:get, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        to_return(status: 200, body: current_settings.to_json, headers: { 'Content-Type': 'application/json' })

      stub_request(:put, "https://api.github.com/repos/exercism/#{repo.name}/branches/main/protection").
        with(body: hash_including({
          required_status_checks: {
            strict: false,
            checks: current_settings[:required_status_checks][:checks]
          }
        })).
        to_return(status: 200)
    end

    Github::Repository::UpdateBranchProtection.(repos)
  end

  private
  def current_branch_protection_settings
    {
      required_status_checks: {
        strict: false,
        checks: []
      },
      required_pull_request_reviews: {
        dismiss_stale_reviews: true,
        require_code_owner_reviews: true,
        required_approving_review_count: 1
      },
      required_signatures: { enabled: false },
      enforce_admins: { enabled: false },
      required_linear_history: { enabled: false },
      allow_force_pushes: { enabled: false },
      allow_deletions: { enabled: false },
      block_creations: { enabled: false },
      required_conversation_resolution: { enabled: false }
    }
  end
end
