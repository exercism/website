require "test_helper"

class User::ReputationToken::AwardForPullRequestTest < ActiveSupport::TestCase
  test "award reputation to pull request author" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(
      action:, author_username: login, url:, html_url:,
      labels:, repo:, node_id:, number:, merged:, merged_at:
    )

    assert User::ReputationTokens::CodeContributionToken.where(user:).exists?
  end

  test "award reputation to pull request reviewers" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = false
    closed_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"
    create :github_organization_member, username: "reviewer71"
    create :github_organization_member, username: "reviewer13"
    reviews = [
      { reviewer_username: reviewer_1.github_username },
      { reviewer_username: reviewer_2.github_username }
    ]

    User::ReputationToken::AwardForPullRequest.(
      action:, author_username: login, url:, html_url:, labels:,
      repo:, node_id:, number:, merged:, closed_at:, reviews:
    )

    assert User::ReputationTokens::CodeReviewToken.where(user: reviewer_1).exists?
    assert User::ReputationTokens::CodeReviewToken.where(user: reviewer_2).exists?
  end

  test "don't award reputation for pull request reviewers if there were no reviewers" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = false
    closed_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviews = []

    User::ReputationToken::AwardForPullRequest.(
      action:, author_username: login, url:, html_url:, labels:,
      repo:, node_id:, number:, merged:, closed_at:, reviews:
    )

    refute User::ReputationTokens::CodeReviewToken.exists?
  end

  test "award reputation to pull request merger" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    merger = create :user, handle: "Merged-88", github_username: "merger88"

    User::ReputationToken::AwardForPullRequest.(
      action:, author_username: login, url:, html_url:, labels:,
      repo:, node_id:, number:,
      merged:, merged_at:, merged_by_username: merger.github_username
    )

    assert User::ReputationTokens::CodeMergeToken.where(user: merger).exists?
  end

  test "don't award reputation for pull request merged if the pull request was not merged" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    User::ReputationToken::AwardForPullRequest.(
      action:, author_username: login, url:, html_url:,
      labels:, repo:, node_id:, number:, merged:
    )

    refute User::ReputationTokens::CodeMergeToken.exists?
  end

  test "award reputation for pull request review and merge by the same user" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = true
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    helpful_user = create :user, handle: "Helpful-user", github_username: "helpful_user"
    create :github_organization_member, username: "helpful_user"
    reviews = [{ reviewer_username: helpful_user.github_username }]

    User::ReputationToken::AwardForPullRequest.(
      action:, author_username: login, url:, html_url:, labels:, reviews:,
      repo:, node_id:, number:,
      merged:, merged_at:, merged_by_username: helpful_user.github_username
    )

    assert_equal 6, helpful_user.reload.reputation
    assert_equal 2, User::ReputationToken.where(user: helpful_user).size
    assert User::ReputationTokens::CodeMergeToken.where(user: helpful_user).one?
    assert User::ReputationTokens::CodeReviewToken.where(user: helpful_user).one?
  end
end
