require "test_helper"

class User::ReputationToken::AwardForPullRequestTest < ActiveSupport::TestCase
  test "adds reputation token to pull request author when action is closed" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    assert user.reputation_tokens.where(context_key: 'contributed_code/v3/pulls/1347').exists?
  end

  test "reputation is awarded once per author per pull request" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User22", github_username: "user22"
    create :user_reputation_token, user: user, reason: 'contributed_code', context_key: 'contributed_code/v3/pulls/1347', category: :building # rubocop:disable Layout/LineLength

    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    assert_equal 1, user.reputation_tokens.where(context_key: 'contributed_code/v3/pulls/1347').size
  end

  test "reputation not awarded if pull request author is not known" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    refute User::ReputationToken.where(context_key: 'contributed_code/v3/pulls/1347').exists?
  end

  test "pull request without labels adds reputation token with default value" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    reputation_token = user.reputation_tokens.find_by(context_key: 'contributed_code/v3/pulls/1347')
    assert_equal 10, reputation_token.value
  end

  test "pull request with reputation/contributed_code/regular label adds reputation token with default value" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/regular']
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    reputation_token = user.reputation_tokens.find_by(context_key: 'contributed_code/v3/pulls/1347')
    assert_equal 10, reputation_token.value
  end

  test "pull request with reputation/contributed_code/minor label adds reputation token with lower value" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor']
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    reputation_token = user.reputation_tokens.find_by(context_key: 'contributed_code/v3/pulls/1347')
    assert_equal 5, reputation_token.value
  end

  test "pull request with reputation/contributed_code/major label adds reputation token with higher value" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    reputation_token = user.reputation_tokens.find_by(context_key: 'contributed_code/v3/pulls/1347')
    assert_equal 15, reputation_token.value
  end

  test "pull request with added label updates reputation value" do
    action = 'labeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor']
    user = create :user, handle: "User22", github_username: "user22"
    reputation_token = create :user_reputation_token, user: user, reason: 'contributed_code', context_key: 'contributed_code/v3/pulls/1347', category: :building # rubocop:disable Layout/LineLength

    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    assert_equal 1, user.reputation_tokens.size
    assert_equal 5, reputation_token.reload.value
  end

  test "pull request with changed label updates reputation value" do
    action = 'labeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User22", github_username: "user22"
    reputation_token = create :user_reputation_token, user: user, reason: 'contributed_code/minor', context_key: 'contributed_code/v3/pulls/1347', category: :building # rubocop:disable Layout/LineLength

    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    assert_equal 1, user.reputation_tokens.size
    assert_equal 15, reputation_token.reload.value
  end

  test "pull request with removed label updates reputation value" do
    action = 'labeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User22", github_username: "user22"
    reputation_token = create :user_reputation_token, user: user, reason: 'contributed_code/minor', context_key: 'contributed_code/v3/pulls/1347', category: :building # rubocop:disable Layout/LineLength
    User::ReputationToken::AwardForPullRequest.(action, login, url: url, html_url: html_url, labels: labels)

    assert_equal 1, user.reputation_tokens.size
    assert_equal 10, reputation_token.reload.value
  end
end
