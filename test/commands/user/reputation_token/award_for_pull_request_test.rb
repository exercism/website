require "test_helper"

class User::ReputationToken::AwardForPullRequestTest < ActiveSupport::TestCase
  test "adds reputation token to pull request author when action is closed" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(action, login, url, html_url)

    assert user.reputation_tokens.where(reason: 'contributed_code', external_link: 'https://github.com/exercism/v3/pull/1347').exists?
  end

  test "reputation is awarded once per author per pull request" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    user = create :user, handle: "User22", github_username: "user22"
    create :user_reputation_token, user: user, reason: 'contributed_code', category: :building

    User::ReputationToken::AwardForPullRequest.(action, login, url, html_url)

    assert_equal 1, user.reputation_tokens.where(reason: 'contributed_code', external_link: 'https://github.com/exercism/v3/pull/1347').size
  end
end
