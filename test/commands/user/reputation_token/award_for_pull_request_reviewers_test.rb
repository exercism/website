require "test_helper"

class User::ReputationToken::AwardForPullRequestReviewersTest < ActiveSupport::TestCase
  test "pull request reviewers are awarded reputation on closed action when pull request is merged" do
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
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"
    create :github_organization_member, username: "reviewer71"
    create :github_organization_member, username: "reviewer13"
    reviews = [
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    reputation_token_1 = reviewer_1.reputation_tokens.last
    assert_equal 5, reputation_token_1.value

    reputation_token_2 = reviewer_2.reputation_tokens.last
    assert_equal 5, reputation_token_2.value
  end

  test "pull request reviewers are awarded reputation on closed action even when pull request is not merged" do
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
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"
    create :github_organization_member, username: "reviewer71"
    create :github_organization_member, username: "reviewer13"
    reviews = [
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    reputation_token_1 = reviewer_1.reputation_tokens.last
    assert_equal 5, reputation_token_1.value

    reputation_token_2 = reviewer_2.reputation_tokens.last
    assert_equal 5, reputation_token_2.value
  end

  test "pull request reviewers are not awarded reputation on labeled action" do
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
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_empty reviewer.reputation_tokens
  end

  test "pull request reviewers are not awarded reputation on unlabeled action" do
    action = 'unlabeled'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_empty reviewer.reputation_tokens
  end

  test "pull request authors are not awarded reputation for reviewing their own pull request" do
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
    create :github_organization_member, username: "user22"
    reviews = [{ reviewer_username: "user22" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    refute User::ReputationTokens::CodeReviewToken.where(user: user).exists?
  end

  test "pull request reviewers are only awarded reputation once per pull request" do
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
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"
    create :github_organization_member, username: "reviewer71"
    create :github_organization_member, username: "reviewer13"
    reviews = [
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" },
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_equal 1, reviewer_1.reputation_tokens.size
    assert_equal 1, reviewer_2.reputation_tokens.size
  end

  test "skip over reviews with missing reviewer username" do
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
    create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :user, handle: "Reviewer-13", github_username: "reviewer13"
    create :github_organization_member, username: "reviewer71"
    create :github_organization_member, username: "reviewer13"
    reviews = [
      { reviewer_username: nil },
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_equal 2, User::ReputationTokens::CodeReviewToken.find_each.size
  end

  test "pull request reviewers are only awarded reputation if they are organization members" do
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
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"
    create :github_organization_member, username: "reviewer71"
    reviews = [
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    refute_empty reviewer_1.reputation_tokens
    assert_empty reviewer_2.reputation_tokens
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
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_equal 2, reviewer.reputation_tokens.last.value
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
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_equal 10, reviewer.reputation_tokens.last.value
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
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_equal 10, reviewer.reputation_tokens.last.value
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
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"    
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_equal 5, reviewer.reputation_tokens.last.value
  end

  test "pull request with added label updates reputation value" do
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
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    reputation_token = create :user_code_review_reputation_token,
      user: reviewer,
      level: :regular,
      params: {
        repo: repo,
        pr_node_id: node_id
      }

    assert_equal :regular, reputation_token.level # Sanity
    assert_equal 5, reputation_token.value # Sanity

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_equal 1, reviewer.reputation_tokens.size
    assert_equal :minor, reputation_token.reload.level
    assert_equal 2, reputation_token.reload.value
  end

  test "pull request with changed label updates reputation value" do
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
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    reputation_token = create :user_code_review_reputation_token,
      user: reviewer,
      level: :minor,
      params: {
        repo: repo,
        pr_node_id: node_id
      }

    assert_equal :minor, reputation_token.level # Sanity
    assert_equal 2, reputation_token.value # Sanity

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_equal 1, reviewer.reputation_tokens.size
    assert_equal :major, reputation_token.reload.level
    assert_equal 10, reputation_token.reload.value
  end

  test "pull request with removed label updates reputation value" do
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
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    reputation_token = create :user_code_review_reputation_token,
      user: reviewer,
      level: :minor,
      params: {
        repo: repo,
        pr_node_id: node_id
      }

    assert_equal :minor, reputation_token.level # Sanity
    assert_equal 2, reputation_token.value # Sanity

    User::ReputationToken::AwardForPullRequestReviewers.(
      action: action, author_username: author, url: url, html_url: html_url, labels: labels,
      repo: repo, node_id: node_id, number: number, title: title, merged: merged, reviews: reviews
    )

    assert_equal 1, reviewer.reputation_tokens.size
    assert_equal :regular, reputation_token.reload.level
    assert_equal 5, reputation_token.reload.value
  end
end
