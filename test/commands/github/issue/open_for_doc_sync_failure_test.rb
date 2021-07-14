require "test_helper"

class Github::Issue::OpenForDocSyncFailureTest < ActiveSupport::TestCase
  test "opens issue when issue was not yet created" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    # Raise the error and catch it to ensure a proper backtrace
    begin
      raise StandardError, "Could not find Concept X"
    rescue StandardError => e
      exception = e
    end

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Document%20sync%20error%20for%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/docs%20author:exercism-bot"). # rubocop:disable Layout/LineLength
      to_return(
        status: 200,
        body: {
          total_count: 0,
          incomplete_results: false,
          items: []
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://api.github.com/repos/exercism/docs/issues").
      with do |request|
        json = JSON.parse(request.body)
        json["labels"].empty? &&
          json["title"] == "🤖 Document sync error for commit 2e25f7" &&
          json["body"].include?("We hit an error trying to sync the latest commit (2e25f799c1830b93a8ad65a2bbbb1c50f381e639) to the website.") && # rubocop:disable Layout/LineLength
          json["body"].include?("Please tag @exercism/maintainers-admin if you require more information.") &&
          json["body"].match?(/open_for_doc_sync_failure_test\.rb:\d+:in `block in <class:OpenForDocSyncFailureTest>/)
      end.
      to_return(status: 200, body: "", headers: {}).
      times(1)

    document = {
      uuid: "7c7139b9-a228-4691-a4e4-a0c39a6dd615",
      section: "contributing",
      slug: "APEX",
      path: "contributing/README.md",
      title: "Contributing to Exercism",
      blurb: "An overview of how to contribute to Exercism"
    }

    Github::Issue::OpenForDocSyncFailure.(document, :building, exception, "2e25f799c1830b93a8ad65a2bbbb1c50f381e639")
  end

  test "re-opens issue when issue was closed" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    # Raise the error and catch it to ensure a proper backtrace
    begin
      raise StandardError, "Could not find Concept X"
    rescue StandardError => e
      exception = e
    end

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Document%20sync%20error%20for%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/docs%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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

    stub_request(:patch, "https://api.github.com/repos/exercism/docs/issues/22").
      with(body: { state: "open" }.to_json).
      to_return(status: 200, body: "", headers: {}).
      times(1)

    document = {
      uuid: "7c7139b9-a228-4691-a4e4-a0c39a6dd615",
      section: "contributing",
      slug: "APEX",
      path: "contributing/README.md",
      title: "Contributing to Exercism",
      blurb: "An overview of how to contribute to Exercism"
    }

    Github::Issue::OpenForDocSyncFailure.(document, :building, exception, "2e25f799c1830b93a8ad65a2bbbb1c50f381e639")
  end

  test "does nothing when issue already open" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    # Raise the error and catch it to ensure a proper backtrace
    begin
      raise StandardError, "Could not find Concept X"
    rescue StandardError => e
      exception = e
    end

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Document%20sync%20error%20for%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/docs%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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

    document = {
      uuid: "7c7139b9-a228-4691-a4e4-a0c39a6dd615",
      section: "contributing",
      slug: "APEX",
      path: "contributing/README.md",
      title: "Contributing to Exercism",
      blurb: "An overview of how to contribute to Exercism"
    }

    Github::Issue::OpenForDocSyncFailure.(document, :building, exception, "2e25f799c1830b93a8ad65a2bbbb1c50f381e639")

    # If the GitHub API would have been called, we would not have gotten to this point
  end
end
