require "test_helper"

class Github::Issue::OpenForDependencyCycleTest < ActiveSupport::TestCase
  test "opens issue when issue was not yet created" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    track = create :track, slug: 'ruby', synced_to_git_sha: '2e25f799c1830b93a8ad65a2bbbb1c50f381e639'

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Concept%20prerequisite%20cycle%20found%20in%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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
          json["title"] == "🤖 Concept prerequisite cycle found in commit 2e25f7" &&
          json["body"].include?("Such a cycle occurs when Concept Exercise A teaches concept X") &&
          json["body"].include?("These prerequisite cycles should be removed to have the track work properly on the website") &&
          json["body"].include?("Please tag @exercism/maintainers-admin if you require more information.")
      end.
      to_return(status: 200, body: "", headers: {}).
      times(1)

    Github::Issue::OpenForDependencyCycle.(track)
  end

  test "re-opens issue when issue was closed" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    track = create :track, slug: 'ruby', synced_to_git_sha: '2e25f799c1830b93a8ad65a2bbbb1c50f381e639'

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Concept%20prerequisite%20cycle%20found%20in%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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

    Github::Issue::OpenForDependencyCycle.(track)
  end

  test "does nothing when issue already open" do
    Exercism.config.stubs(:github_bot_username).returns('exercism-bot')

    track = create :track, slug: 'ruby', synced_to_git_sha: '2e25f799c1830b93a8ad65a2bbbb1c50f381e639'

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=%22%F0%9F%A4%96%20Concept%20prerequisite%20cycle%20found%20in%20commit%202e25f7%22%20is:issue%20in:title%20repo:exercism/ruby%20author:exercism-bot"). # rubocop:disable Layout/LineLength
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

    Github::Issue::OpenForDependencyCycle.(track)

    # If the GitHub API would have been called, we would not have gotten to this point
  end
end
