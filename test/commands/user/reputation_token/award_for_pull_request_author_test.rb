require "test_helper"

class User::ReputationToken::AwardForPullRequestAuthorTest < ActiveSupport::TestCase
  test "adds reputation token to pull request author when action is closed and merged" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert User::ReputationTokens::CodeContributionToken.where(user: user).exists?
  end

  test "reputation is awarded once per author per pull request" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    create :user_code_contribution_reputation_token,
      user: user,
      level: :regular,
      params: {
        repo: repo,
        pr_node_id: node_id
      }

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 1, User::ReputationTokens::CodeContributionToken.where(user: user).size
  end

  test "reputation not awarded to pull request author if author is not known" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    refute User::ReputationTokens::CodeContributionToken.exists?
  end

  test "reputation not awarded to pull request author if pull request is closed but not merged" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_empty User::ReputationTokens::CodeContributionToken.where(user: user)
  end

  test "pull request without labels adds reputation token with default value" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 12, user.reputation_tokens.last.value
  end

  test "pull request with reputation/contributed_code/regular label adds reputation token with default value" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/regular']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 12, user.reputation_tokens.last.value
  end

  test "pull request with reputation/contributed_code/minor label adds reputation token with lower value" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 5, user.reputation_tokens.last.value
  end

  test "pull request with reputation/contributed_code/major label adds reputation token with higher value" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 30, user.reputation_tokens.last.value
  end

  test "pull request with minor and major reputation labels adds reputation token for major reputation" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor', 'reputation/contributed_code/major']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 30, user.reputation_tokens.last.value
  end

  test "pull request ignores irrelevant labels" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 12, user.reputation_tokens.last.value
  end

  test "pull request with added label updates reputation value" do
    action = 'labeled'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor']
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_code_contribution_reputation_token,
      user: user,
      level: :regular,
      params: {
        repo: repo,
        pr_node_id: node_id
      }

    assert_equal :regular, reputation_token.level # Sanity
    assert_equal 12, reputation_token.value # Sanity

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 1, user.reputation_tokens.size
    assert_equal :minor, reputation_token.reload.level
    assert_equal 5, reputation_token.reload.value
  end

  test "pull request with changed label updates reputation value" do
    action = 'labeled'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_code_contribution_reputation_token, user: user, level: :minor,
                                                                        params: { repo: repo, pr_node_id: node_id }

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 1, user.reputation_tokens.size
    assert_equal 30, reputation_token.reload.value
  end

  test "pull request with removed label updates reputation value" do
    action = 'labeled'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_code_contribution_reputation_token, user: user, level: :minor,
                                                                        params: { repo: repo, pr_node_id: node_id }

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_equal 1, user.reputation_tokens.size
    assert_equal 12, reputation_token.reload.value
  end

  test "pull request authors are not awarded reputation on labeled action when pull request has not been merged" do
    action = 'labeled'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_empty User::ReputationTokens::CodeContributionToken.where(user: user)
  end

  test "pull request authors are not awarded reputation on unlabeled action when pull request has not been merged" do
    action = 'unlabeled'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_empty User::ReputationTokens::CodeContributionToken.where(user: user)
  end

  test "pull requests labelled as v3 migration and authored by ErikSchierboom don't award reputation" do
    action = 'closed'
    author = 'ErikSchierboom'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['v3-migration 🤖']
    user = create :user, handle: "ErikSchierboom", github_username: "ErikSchierboom"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_empty User::ReputationTokens::CodeContributionToken.where(user: user)
  end

  test "pull requests with title starting with [v3] and authored by ErikSchierboom don't award reputation" do
    action = 'closed'
    author = 'ErikSchierboom'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "[v3] The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "ErikSchierboom", github_username: "ErikSchierboom"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged
    )

    assert_empty User::ReputationTokens::CodeContributionToken.where(user: user)
  end
end
