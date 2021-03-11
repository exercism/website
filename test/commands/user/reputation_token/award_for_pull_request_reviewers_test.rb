require "test_helper"

class User::ReputationToken::AwardForPullRequestReviewersTest < ActiveSupport::TestCase
  test "pull request reviewers are awarded reputation on closed action when pull request is merged" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"
    reviews = [
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, merged: merged, reviews: reviews
    )

    reputation_token_1 = reviewer_1.reputation_tokens.last
    assert_equal 3, reputation_token_1.value

    reputation_token_2 = reviewer_2.reputation_tokens.last
    assert_equal 3, reputation_token_2.value
  end

  test "pull request reviewers are awarded reputation on closed action even when pull request is not merged" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"
    reviews = [
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, merged: merged, reviews: reviews
    )

    reputation_token_1 = reviewer_1.reputation_tokens.last
    assert_equal 3, reputation_token_1.value

    reputation_token_2 = reviewer_2.reputation_tokens.last
    assert_equal 3, reputation_token_2.value
  end

  test "pull request reviewers are not awarded reputation on labeled action" do
    action = 'labeled'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, merged: merged, reviews: reviews
    )

    assert_empty reviewer.reputation_tokens
  end

  test "pull request reviewers are not awarded reputation on unlabeled action" do
    action = 'unlabeled'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, merged: merged, reviews: reviews
    )

    assert_empty reviewer.reputation_tokens
  end

  test "pull request authors are not awarded reputation for reviewing their own pull request" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    reviews = [{ reviewer_username: "user22" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, merged: merged, reviews: reviews
    )

    refute User::ReputationTokens::CodeReviewToken.where(user: user).exists?
  end

  test "pull request reviewers are only awarded reputation once per pull request" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"
    reviews = [
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" },
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, merged: merged, reviews: reviews
    )

    assert_equal 1, reviewer_1.reputation_tokens.size
    assert_equal 1, reviewer_2.reputation_tokens.size
  end
end
