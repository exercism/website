require "test_helper"

class User::ReputationToken::AwardForPullRequestTest < ActiveSupport::TestCase
  test "adds code contributions for commits made after synced git SHA" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(action, login, url, html_url)

    assert user.reputation_tokens.where(reason: 'committed_code', external_link: 'https://github.com/exercism/v3/pull/1347').exists?
  end
end
