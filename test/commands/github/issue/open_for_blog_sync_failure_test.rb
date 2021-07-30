require "test_helper"

class Github::Issue::OpenForBlogSyncFailureTest < ActiveSupport::TestCase
  setup do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    # Raise the error and catch it to ensure a proper backtrace
    begin
      raise StandardError, "Could not sync the Blog repo"
    rescue StandardError => e
      @exception = e
    end
  end

  test "opens issue when issue was not yet created" do
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Blog%20sync%20error%20for%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/blog%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 0,
          incomplete_results: false,
          items: []
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://api.github.com/repos/exercism/blog/issues").
      with do |request|
        json = JSON.parse(request.body)
        json["labels"].empty? &&
          json["title"] == "🤖 Blog sync error for commit 2e25f7" &&
          json["body"].include?("We hit an error trying to sync the latest commit (2e25f799c1830b93a8ad65a2bbbb1c50f381e639) to the website.") && # rubocop:disable Layout/LineLength
          json["body"].include?("Please tag @exercism/maintainers-admin if you require more information.") &&
          json["body"].match?(/open_for_blog_sync_failure_test\.rb:\d+:in `block in <class:OpenForBlogSyncFailureTest>/)
      end.
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::OpenForBlogSyncFailure.(@exception, "2e25f799c1830b93a8ad65a2bbbb1c50f381e639")
  end

  test "re-opens issue when issue was closed" do
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Blog%20sync%20error%20for%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/blog%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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

    stub_request(:patch, "https://api.github.com/repos/exercism/blog/issues/22").
      with(body: { state: "open" }.to_json).
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::OpenForBlogSyncFailure.(@exception, "2e25f799c1830b93a8ad65a2bbbb1c50f381e639")
  end

  test "does nothing when issue already open" do
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Blog%20sync%20error%20for%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/blog%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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

    Github::Issue::OpenForBlogSyncFailure.(@exception, "2e25f799c1830b93a8ad65a2bbbb1c50f381e639")

    # If the GitHub API would have been called, we would not have gotten to this point
  end
end
