require "test_helper"

class User::ReputationToken::AwardForPullRequestTest < ActiveSupport::TestCase
  test "adds reputation token to pull request author when action is closed" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    assert user.reputation_tokens.where(context_key: 'contributed_code/exercism/v3/pulls/1347').exists?
  end

  test "reputation is awarded once per author per pull request" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User22", github_username: "user22"
    create :user_reputation_token, user: user, reason: 'contributed_code', context_key: 'contributed_code/exercism/v3/pulls/1347', category: :building # rubocop:disable Layout/LineLength

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    assert_equal 1, user.reputation_tokens.where(context_key: 'contributed_code/exercism/v3/pulls/1347').size
  end

  test "reputation not awarded if pull request author is not known" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    refute User::ReputationToken.where(context_key: 'contributed_code/exercism/v3/pulls/1347').exists?
  end

  test "pull request without labels adds reputation token with default value" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    reputation_token = user.reputation_tokens.find_by(context_key: 'contributed_code/exercism/v3/pulls/1347')
    assert_equal 10, reputation_token.value
  end

  test "pull request with reputation/contributed_code/regular label adds reputation token with default value" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/regular']
    user = create :user, handle: "User22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    reputation_token = user.reputation_tokens.find_by(context_key: 'contributed_code/exercism/v3/pulls/1347')
    assert_equal 10, reputation_token.value
  end

  test "pull request with reputation/contributed_code/minor label adds reputation token with lower value" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor']
    user = create :user, handle: "User22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    reputation_token = user.reputation_tokens.find_by(context_key: 'contributed_code/exercism/v3/pulls/1347')
    assert_equal 5, reputation_token.value
  end

  test "pull request with reputation/contributed_code/major label adds reputation token with higher value" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    reputation_token = user.reputation_tokens.find_by(context_key: 'contributed_code/exercism/v3/pulls/1347')
    assert_equal 15, reputation_token.value
  end

  test "pull request with added label updates reputation value" do
    action = 'labeled'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor']
    user = create :user, handle: "User22", github_username: "user22"
    reputation_token = create :user_reputation_token, user: user, reason: 'contributed_code', context_key: 'contributed_code/exercism/v3/pulls/1347', category: :building # rubocop:disable Layout/LineLength

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    assert_equal 1, user.reputation_tokens.size
    assert_equal 5, reputation_token.reload.value
  end

  test "pull request with changed label updates reputation value" do
    action = 'labeled'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User22", github_username: "user22"
    reputation_token = create :user_reputation_token, user: user, reason: 'contributed_code/minor', context_key: 'contributed_code/exercism/v3/pulls/1347', category: :building # rubocop:disable Layout/LineLength

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    assert_equal 1, user.reputation_tokens.size
    assert_equal 15, reputation_token.reload.value
  end

  test "pull request with removed label updates reputation value" do
    action = 'labeled'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User22", github_username: "user22"
    reputation_token = create :user_reputation_token, user: user, reason: 'contributed_code/minor', context_key: 'contributed_code/exercism/v3/pulls/1347', category: :building # rubocop:disable Layout/LineLength

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    assert_equal 1, user.reputation_tokens.size
    assert_equal 10, reputation_token.reload.value
  end

  test "pull request reviewers are awarded reputation on closed action" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer_1 = create :user, handle: "Reviewer71", github_username: "Reviewer71"
    reviewer_2 = create :user, handle: "Reviewer13", github_username: "Reviewer13"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [
        { user: { login: "Reviewer71" } },
        { user: { login: "Reviewer13" } }
      ].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    reputation_token_1 = reviewer_1.reputation_tokens.find_by(context_key: 'reviewed_code/exercism/v3/pulls/1347')
    assert_equal 3, reputation_token_1.value

    reputation_token_2 = reviewer_2.reputation_tokens.find_by(context_key: 'reviewed_code/exercism/v3/pulls/1347')
    assert_equal 3, reputation_token_2.value
  end

  test "pull request reviewers are not awarded reputation on labeled action" do
    action = 'labeled'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer71", github_username: "Reviewer71"

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    assert_empty reviewer.reputation_tokens
  end

  test "pull request reviewers are not awarded reputation on unlabeled action" do
    action = 'unlabeled'
    login = 'user22'
    repo = 'exercism/v3'
    number = 1347
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer71", github_username: "Reviewer71"

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, number: number)

    assert_empty reviewer.reputation_tokens
  end
end
