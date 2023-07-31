require "test_helper"

class Github::Issue::OpenForTrackSyncFailureTest < ActiveSupport::TestCase
  test "opens issue when issue was not yet created" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    git_sha = "2e25f799c1830b93a8ad65a2bbbb1c50f381e639"

    # Raise the error and catch it to ensure a proper backtrace
    begin
      raise StandardError, "Could not find Concept X"
    rescue StandardError => e
      exception = e
    end

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Sync%20error%20for%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 0,
          incomplete_results: false,
          items: []
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://api.github.com/repos/exercism/ruby/issues").
      with do |request|
        json = JSON.parse(request.body)
        json["labels"].empty? &&
          json["title"] == "🤖 Sync error for commit 2e25f7" &&
          json["body"].include?("We hit an error trying to sync the latest commit (2e25f799c1830b93a8ad65a2bbbb1c50f381e639) to the website.") && # rubocop:disable Layout/LineLength
          json["body"].include?("Please tag @exercism/maintainers-admin if you require more information.") &&
          json["body"].match?(/open_for_track_sync_failure_test\.rb:\d+:in `block in <class:OpenForTrackSyncFailureTest>/)
      end.
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::OpenForTrackSyncFailure.(create(:track, slug: 'ruby'), exception, git_sha)
  end

  test "re-opens issue when issue was closed" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    git_sha = "2e25f799c1830b93a8ad65a2bbbb1c50f381e639"

    # Raise the error and catch it to ensure a proper backtrace
    begin
      raise StandardError, "Could not find Concept X"
    rescue StandardError => e
      exception = e
    end

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Sync%20error%20for%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 1,
          incomplete_results: false,
          items: [{
            number: 22,
            state: "closed"
          }]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:patch, "https://api.github.com/repos/exercism/ruby/issues/22").
      with(body: { state: "open" }.to_json).
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::OpenForTrackSyncFailure.(create(:track, slug: 'ruby'), exception, git_sha)
  end

  test "does nothing when issue already open" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    git_sha = "2e25f799c1830b93a8ad65a2bbbb1c50f381e639"

    # Raise the error and catch it to ensure a proper backtrace
    begin
      raise StandardError, "Could not find Concept X"
    rescue StandardError => e
      exception = e
    end

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Sync%20error%20for%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 1,
          incomplete_results: false,
          items: [{
            number: 22,
            state: "open"
          }]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    Github::Issue::OpenForTrackSyncFailure.(create(:track, slug: 'ruby'), exception, git_sha)

    # If the GitHub API would have been called, we would not have gotten to this point
  end

  test "does nothing when exception is deadlock" do
    exception = ActiveRecord::Deadlocked.new

    Github::Issue::OpenForTrackSyncFailure.(create(:track), exception, nil)

    # If the GitHub API would have been called, we would not have gotten to this point
  end

  test "different title without sha" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    # Raise the error and catch it to ensure a proper backtrace
    begin
      raise StandardError, "Could not find Concept X"
    rescue StandardError => e
      exception = e
    end

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Sync%20error%3A%20Could%20not%20find%20main%20branch%22%20is:issue%20in:title%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 0,
          incomplete_results: false,
          items: []
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://api.github.com/repos/exercism/ruby/issues").
      with do |request|
        json = JSON.parse(request.body)
        json["labels"].empty? &&
          json["title"] == "🤖 Sync error: Could not find main branch" &&
          json["body"].include?("We hit an error trying to sync the latest commit (unknown) to the website.") &&
          json["body"].include?("Please tag @exercism/maintainers-admin if you require more information.") &&
          json["body"].match?(/open_for_track_sync_failure_test\.rb:\d+:in `block in <class:OpenForTrackSyncFailureTest>/)
      end.
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::OpenForTrackSyncFailure.(create(:track, slug: 'ruby'), exception, nil)
  end
end
