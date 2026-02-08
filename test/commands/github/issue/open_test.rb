require "test_helper"

class Github::Issue::OpenTest < ActiveSupport::TestCase
  setup do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')
  end

  test "opens issue when issue was not yet created" do
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22Test%20title%22%20is:issue%20in:title%20repo:exercism/ruby-analyzer%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 0,
          incomplete_results: false,
          items: []
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://api.github.com/repos/exercism/ruby-analyzer/issues").
      with do |request|
        json = JSON.parse(request.body)
        json["title"] == "Test title" &&
          json["body"] == "Test body"
      end.
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::Open.("exercism/ruby-analyzer", "Test title", "Test body")
  end

  test "re-opens issue when issue was closed" do
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22Test%20title%22%20is:issue%20in:title%20repo:exercism/ruby-analyzer%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 1,
          incomplete_results: false,
          items: [{
            number: 42,
            state: "closed"
          }]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:patch, "https://api.github.com/repos/exercism/ruby-analyzer/issues/42").
      with(body: { state: "open" }.to_json).
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::Open.("exercism/ruby-analyzer", "Test title", "Test body")
  end

  test "does nothing when issue already open" do
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22Test%20title%22%20is:issue%20in:title%20repo:exercism/ruby-analyzer%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 1,
          incomplete_results: false,
          items: [{
            number: 42,
            state: "open"
          }]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    Github::Issue::Open.("exercism/ruby-analyzer", "Test title", "Test body")

    # If the GitHub API would have been called to create/reopen, we would not have gotten to this point
  end

  test "sanitizes curly braces from title in search query" do
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22keymentoring_request_url%20not%20found%22%20is:issue%20in:title%20repo:exercism/ruby-analyzer%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 0,
          incomplete_results: false,
          items: []
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://api.github.com/repos/exercism/ruby-analyzer/issues").
      with do |request|
        json = JSON.parse(request.body)
        json["title"] == "key{mentoring_request_url} not found"
      end.
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::Open.("exercism/ruby-analyzer", "key{mentoring_request_url} not found", "backtrace")
  end

  test "creates issue when search returns UnprocessableEntity" do
    stub_request(:get, %r{api\.github\.com/search/issues}).
      to_return(status: 422, body: "", headers: {})

    stub_request(:post, "https://api.github.com/repos/exercism/ruby-analyzer/issues").
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::Open.("exercism/ruby-analyzer", "key{mentoring_request_url} not found", "backtrace")
  end

  test "does nothing in development environment" do
    # Unstub github_bot_username since it won't be called (early return)
    Exercism.config.unstub(:github_bot_username)
    Rails.env.stubs(:development?).returns(true)

    Github::Issue::Open.("exercism/ruby-analyzer", "Test title", "Test body")

    # No API calls should be made - if they were, WebMock would raise
  end
end
