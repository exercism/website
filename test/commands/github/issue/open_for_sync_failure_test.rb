require "test_helper"

class Github::Issue::OpenForSyncFailureTest < ActiveSupport::TestCase
  test "opens issue when issue was not yet created" do
    head_git_sha = "2e25f799c1830b93a8ad65a2bbbb1c50f381e639"

    # We raise the error and then catch it to make sure that the
    # error has a proper backtrace
    begin
      raise StandardError, "Could not find Concept X"
    rescue StandardError => e
      error = e
    end

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

    body = <<~BODY.strip
      We hit an error trying to sync the latest commit (2e25f799c1830b93a8ad65a2bbbb1c50f381e639) to the website.

      The error was:
      ```
      Could not find Concept X

      ["/usr/src/app/test/commands/github/issue/open_for_sync_failure_test.rb:10:in `block in <class:OpenForSyncFailureTest>'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:272:in `time_it'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest/test.rb:94:in `block in run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:367:in `on_signal'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest/test.rb:211:in `with_info_handler'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest/test.rb:93:in `run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:1029:in `run_one_method'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:341:in `run_one_method'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:328:in `block (2 levels) in run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:327:in `each'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:327:in `block in run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:367:in `on_signal'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:354:in `with_info_handler'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:326:in `run'", "/usr/local/bundle/gems/railties-6.1.3.1/lib/rails/test_unit/line_filtering.rb:10:in `run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:164:in `block in __run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:164:in `map'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:164:in `__run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:141:in `run'", "/usr/local/bundle/gems/minitest-5.14.4/lib/minitest.rb:68:in `block in autorun'", "/usr/local/bundle/gems/activesupport-6.1.3.1/lib/active_support/fork_tracker.rb:8:in `fork'", "/usr/local/bundle/gems/activesupport-6.1.3.1/lib/active_support/fork_tracker.rb:8:in `fork'", "/usr/local/bundle/gems/activesupport-6.1.3.1/lib/active_support/fork_tracker.rb:26:in `fork'", "/usr/local/lib/ruby/2.6.0/rubygems/core_ext/kernel_require.rb:54:in `require'", "/usr/local/lib/ruby/2.6.0/rubygems/core_ext/kernel_require.rb:54:in `require'", "-e:1:in `<main>'"]
      ```

      Please tag @iHiD if you require more information.
    BODY

    stub_request(:post, "https://api.github.com/repos/exercism/ruby/issues").
      with(
        body: {
          "labels": [],
          "title": "🤖 Sync error for commit 2e25f7",
          "body": body
        }.to_json.
        gsub('\u003c', '<'). # Required due to Octokit not escaping unicode characters
        gsub('\u003e', '>') # Required due to Octokit not escaping unicode characters
      ).
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::OpenForSyncFailure.(track, error, track.git_head_sha)
  end

  test "re-opens issue when issue was closed" do
    head_git_sha = "2e25f799c1830b93a8ad65a2bbbb1c50f381e639"
    error = StandardError.new "Could not find Concept X"

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

    Github::Issue::OpenForSyncFailure.(track, error, track.git_head_sha)
  end

  test "does nothing when issue already open" do
    head_git_sha = "2e25f799c1830b93a8ad65a2bbbb1c50f381e639"
    error = StandardError.new "Could not find Concept X"

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

    Github::Issue::OpenForSyncFailure.(track, error, track.git_head_sha)

    # If the GitHub API would have been called, we would not have gotten to this point
  end
end
