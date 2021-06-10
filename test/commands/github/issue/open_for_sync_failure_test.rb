require "test_helper"

class Github::Issue::OpenForSyncFailureTest < ActiveSupport::TestCase
  test "opens issue when issue was not yet created" do
    head_git_sha = "2e25f799c1830b93a8ad65a2bbbb1c50f381e639"
    error_message = "Could not find Concept X"

    track = create :track, slug: 'ruby'
    track.stubs(:git_head_sha).returns(head_git_sha)

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=2e25f799c1830b93a8ad65a2bbbb1c50f381e639%20is:issue%20in:body%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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
      with(
        body: {
          labels: [],
          title: "🤖 Sync error for commit 2e25f7",
          body: "We hit an error trying to sync the latest commit (2e25f799c1830b93a8ad65a2bbbb1c50f381e639) to the website.\n\nThe error was:\n```\nCould not find Concept X\n```\n\nPlease tag @iHiD if you require more information." # rubocop:disable Layout/LineLength
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::OpenForSyncFailure.(track, error_message, track.git_head_sha)
  end

  test "re-opens issue when issue was closed" do
    head_git_sha = "2e25f799c1830b93a8ad65a2bbbb1c50f381e639"
    error_message = "Could not find Concept X"

    track = create :track, slug: 'ruby'
    track.stubs(:git_head_sha).returns(head_git_sha)

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=2e25f799c1830b93a8ad65a2bbbb1c50f381e639%20is:issue%20in:body%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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

    Github::Issue::OpenForSyncFailure.(track, error_message, track.git_head_sha)
  end

  test "does nothing when issue already open" do
    head_git_sha = "2e25f799c1830b93a8ad65a2bbbb1c50f381e639"
    error_message = "Could not find Concept X"

    track = create :track, slug: 'ruby'
    track.stubs(:git_head_sha).returns(head_git_sha)

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=2e25f799c1830b93a8ad65a2bbbb1c50f381e639%20is:issue%20in:body%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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

    Github::Issue::OpenForSyncFailure.(track, error_message, track.git_head_sha)

    # If the GitHub API would have been called, we would not have gotten to this point
  end
end
