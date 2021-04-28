require "test_helper"

class User::ReputationToken::AwardForPullRequestMergerTest < ActiveSupport::TestCase
  test "adds reputation token to pull request merger when action is closed and merged" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "Merger-22", github_username: "merger22"

    User::ReputationToken::AwardForPullRequestMerger.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, merged_by_username: merged_by
    )

    assert User::ReputationTokens::CodeMergeToken.where(user: user).exists?
  end

  test "reputation is awarded once per merger per pull request" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "Merger-22", github_username: "merger22"
    create :user_code_merge_reputation_token,
      user: user,
      level: :janitorial,
      params: {
        repo: repo,
        pr_node_id: node_id
      }

    User::ReputationToken::AwardForPullRequestMerger.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, merged_by_username: merged_by
    )

    assert_equal 1, User::ReputationTokens::CodeMergeToken.where(user: user).size
  end

  test "reputation not awarded to pull request merger if merger is not known" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    User::ReputationToken::AwardForPullRequestMerger.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, merged_by_username: merged_by
    )

    refute User::ReputationTokens::CodeMergeToken.exists?
  end

  test "reputation not awarded to pull request merger if pull request is closed but not merged" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = false
    merged_by = nil
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "Merger-22", github_username: "merger22"

    User::ReputationToken::AwardForPullRequestMerger.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, merged_by_username: merged_by
    )

    refute User::ReputationTokens::CodeMergeToken.where(user: user).exists?
  end

  test "reputation not awarded to pull request merger if pull request merger is also the author" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_by = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestMerger.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, merged_by_username: merged_by
    )

    refute User::ReputationTokens::CodeMergeToken.where(user: user).exists?
  end

  test "pull request adds reputation token with janitorial level value if reviewed" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "Merger-22", github_username: "merger22"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestMerger.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels, reviews: reviews,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, merged_by_username: merged_by
    )

    token = user.reputation_tokens.last
    assert_equal 1, token.value
    assert_equal :janitorial, token.level
  end

  test "pull request adds reputation token with reviewal level value if not reviewed" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "Merger-22", github_username: "merger22"
    reviews = []

    User::ReputationToken::AwardForPullRequestMerger.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels, reviews: reviews,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, merged_by_username: merged_by
    )

    token = user.reputation_tokens.last
    assert_equal 5, token.value
    assert_equal :reviewal, token.level
  end
end
