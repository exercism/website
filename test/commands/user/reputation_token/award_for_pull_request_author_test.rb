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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
    )

    assert User::ReputationTokens::CodeContributionToken.where(user:).exists?
  end

  test "reputation is awarded once per author per pull request" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    create :user_code_contribution_reputation_token,
      user:,
      level: :medium,
      params: {
        repo:,
        pr_node_id: node_id,
        merged_at:
      }

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
    )

    assert_equal 1, User::ReputationTokens::CodeContributionToken.where(user:).size
  end

  test "reputation not awarded to pull request author if author is not known" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
    )

    refute User::ReputationTokens::CodeContributionToken.exists?
  end

  test "reputation not awarded to pull request author if author is exercism-bot" do
    action = 'closed'
    author = 'exercism-bot'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    create :user, :system

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
    )

    refute User::ReputationTokens::CodeContributionToken.exists?
  end

  test "reputation not awarded to pull request author if author is exercism-ghost" do
    action = 'closed'
    author = 'exercism-ghost'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    create :user, :ghost

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
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
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:
    )

    assert_empty User::ReputationTokens::CodeContributionToken.where(user:)
  end

  test "pull request without labels adds reputation token with correct value" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
    )

    assert_equal 12, user.reputation_tokens.last.value
  end

  [
    ['x:size/tiny', 3],
    ['x:size/small', 5],
    ['x:size/medium', 12],
    ['x:size/large', 30],
    ['x:size/massive', 100],
    ['x:rep/tiny', 3],
    ['x:rep/small', 5],
    ['x:rep/medium', 12],
    ['x:rep/large', 30],
    ['x:rep/massive', 100]
  ].each do |label, reputation|
    test "pull request with #{label} label adds reputation token with correct value" do
      action = 'closed'
      author = 'user22'
      repo = 'exercism/v3'
      node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      number = 1347
      title = "The cat sat on the mat"
      merged = true
      merged_at = Time.parse('2020-04-03T14:54:57Z').utc
      url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
      html_url = 'https://github.com/exercism/v3/pull/1347'
      labels = [label]
      user = create :user, handle: "User-22", github_username: "user22"

      User::ReputationToken::AwardForPullRequestAuthor.(
        action:, author_username: author, url:, html_url:, labels:,
        repo:, node_id:, number:, title:, merged:, merged_at:
      )

      assert_equal reputation, user.reputation_tokens.last.value
    end
  end

  test "pull request with small and large sizes adds reputation token for greatest size" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['x:size/small', 'x:size/large']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
    )

    assert_equal 30, user.reputation_tokens.last.value
  end

  test "pull request with small and large rep adds reputation token for greatest rep" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['x:rep/small', 'x:rep/large']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['x:rep/small']
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_code_contribution_reputation_token,
      user:,
      level: :medium,
      params: {
        repo:,
        pr_node_id: node_id,
        merged_at:
      }

    assert_equal :medium, reputation_token.level # Sanity
    assert_equal 12, reputation_token.value # Sanity

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
    )

    assert_equal 1, user.reputation_tokens.size
    assert_equal :small, reputation_token.reload.level
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['x:rep/large']
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_code_contribution_reputation_token,
      user:, level: :small, params: { repo:, pr_node_id: node_id, merged_at: }

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_code_contribution_reputation_token,
      user:, level: :small, params: { repo:, pr_node_id: node_id, merged_at: }

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
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
    labels = ['x:rep/large']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:
    )

    assert_empty User::ReputationTokens::CodeContributionToken.where(user:)
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
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:
    )

    assert_empty User::ReputationTokens::CodeContributionToken.where(user:)
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
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequestAuthor.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:
    )

    token = User::ReputationTokens::CodeContributionToken.find { |t| t.params["pr_node_id"] == node_id }
    assert_equal merged_at.to_date, token.earned_on
  end
end
