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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "Merger-22", github_username: "merger22"

    User::ReputationToken::AwardForPullRequestMerger.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, merged_by_username: merged_by
    )

    assert User::ReputationTokens::CodeMergeToken.where(user:).exists?
  end

  test "reputation is awarded once per merger per pull request" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "Merger-22", github_username: "merger22"
    create :user_code_merge_reputation_token,
      user:,
      level: :janitorial,
      params: {
        repo:,
        pr_node_id: node_id,
        merged_at:
      }

    User::ReputationToken::AwardForPullRequestMerger.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, merged_by_username: merged_by
    )

    assert_equal 1, User::ReputationTokens::CodeMergeToken.where(user:).size
  end

  test "reputation not awarded to pull request merger if merger is exercism-bot" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    merged_by = "exercism-bot"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    create :user, :system

    User::ReputationToken::AwardForPullRequestMerger.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, merged_by_username: merged_by
    )

    refute User::ReputationTokens::CodeMergeToken.exists?
  end

  test "reputation not awarded to pull request merger if merger is exercism-ghost" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    merged_by = "exercism-ghost"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    create :user, :ghost

    User::ReputationToken::AwardForPullRequestMerger.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, merged_by_username: merged_by
    )

    refute User::ReputationTokens::CodeMergeToken.exists?
  end

  test "reputation not awarded to pull request merger if merger is not known" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    User::ReputationToken::AwardForPullRequestMerger.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, merged_by_username: merged_by
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
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:,
      merged:, merged_by_username: merged_by
    )

    refute User::ReputationTokens::CodeMergeToken.where(user:).exists?
  end

  test "reputation not awarded to pull request merger if pull request merger is also the author" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    merged_by = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestMerger.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, merged_by_username: merged_by
    )

    refute User::ReputationTokens::CodeMergeToken.where(user:).exists?
  end

  test "pull request adds reputation token with janitorial level value if reviewed" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "Merger-22", github_username: "merger22"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestMerger.(
      action:, author_username: author, url:, html_url:, labels:, reviews:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, merged_by_username: merged_by
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "Merger-22", github_username: "merger22"
    reviews = []

    User::ReputationToken::AwardForPullRequestMerger.(
      action:, author_username: author, url:, html_url:, labels:, reviews:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, merged_by_username: merged_by
    )

    token = user.reputation_tokens.last
    assert_equal 5, token.value
    assert_equal :reviewal, token.level
  end

  test "sets earned on date to pull request merged date when pull request was merged" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    merged_by = "merger22"
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    create :user, handle: "Merger-22", github_username: "merger22"

    User::ReputationToken::AwardForPullRequestMerger.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, merged_by_username: merged_by
    )

    token = User::ReputationTokens::CodeMergeToken.find { |t| t.params["pr_node_id"] == node_id }
    assert_equal merged_at.to_date, token.earned_on
  end
end
