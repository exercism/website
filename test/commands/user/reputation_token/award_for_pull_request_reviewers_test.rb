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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
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
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
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
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    create :github_organization_member, username: "user22"
    reviews = [{ reviewer_username: "user22" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
    )

    refute User::ReputationTokens::CodeReviewToken.where(user:).exists?
  end

  test "pull request reviewers are only awarded reputation once per pull request" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = false
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
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
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
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
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
    )

    assert_equal 2, User::ReputationTokens::CodeReviewToken.find_each.size
  end

  test "skip over reviews with reviewer username is exercism-bot" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = false
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    system_user = create :user, :system
    create :user, handle: "Reviewer-13", github_username: "reviewer13"
    create :github_organization_member, username: "exercism-bot"
    create :github_organization_member, username: "reviewer13"
    reviews = [
      { reviewer_username: "exercism-bot" },
      { reviewer_username: "reviewer71" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
    )

    assert_empty User::ReputationTokens::CodeReviewToken.where(user: system_user)
  end

  test "skip over reviews with reviewer username is exercism-ghost" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = false
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    ghost_user = create :user, :ghost
    create :user, handle: "Reviewer-13", github_username: "reviewer13"
    create :github_organization_member, username: "exercism-ghost"
    create :github_organization_member, username: "reviewer13"
    reviews = [
      { reviewer_username: "exercism-ghost" },
      { reviewer_username: "reviewer71" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
    )

    assert_empty User::ReputationTokens::CodeReviewToken.where(user: ghost_user)
  end

  test "pull request reviewers are only awarded reputation if they are organization members" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    merged = false
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
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
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
    )

    refute_empty reviewer_1.reputation_tokens
    assert_empty reviewer_2.reputation_tokens
  end

  [
    ['x:size/tiny', 1],
    ['x:size/small', 2],
    ['x:size/medium', 5],
    ['x:size/large', 10],
    ['x:size/massive', 20],
    ['x:rep/tiny', 1],
    ['x:rep/small', 2],
    ['x:rep/medium', 5],
    ['x:rep/large', 10],
    ['x:rep/massive', 20]
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
      reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
      create :github_organization_member, username: "reviewer71"
      reviews = [{ reviewer_username: "reviewer71" }]

      User::ReputationToken::AwardForPullRequestReviewers.(
        action:, author_username: author, url:, html_url:, labels:,
        repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
      )

      assert_equal reputation, reviewer.reputation_tokens.last.value
    end
  end

  test "pull request with small and large labels adds reputation token for greatest reputation" do
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
    labels = ['x:size/small', 'x:rep/large']
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['x:size/small']
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    reputation_token = create :user_code_review_reputation_token,
      user: reviewer,
      level: :medium,
      params: {
        repo:,
        pr_node_id: node_id,
        merged_at:
      }

    assert_equal :medium, reputation_token.level # Sanity
    assert_equal 5, reputation_token.value # Sanity

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
    )

    assert_equal 1, reviewer.reputation_tokens.size
    assert_equal :small, reputation_token.reload.level
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['x:size/large']
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    reputation_token = create :user_code_review_reputation_token,
      user: reviewer,
      level: :small,
      params: {
        repo:,
        pr_node_id: node_id,
        merged_at:
      }

    assert_equal :small, reputation_token.level # Sanity
    assert_equal 2, reputation_token.value # Sanity

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
    )

    assert_equal 1, reviewer.reputation_tokens.size
    assert_equal :large, reputation_token.reload.level
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
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    create :github_organization_member, username: "reviewer71"
    reviews = [{ reviewer_username: "reviewer71" }]

    reputation_token = create :user_code_review_reputation_token,
      user: reviewer,
      level: :small,
      params: {
        repo:,
        pr_node_id: node_id,
        merged_at:
      }

    assert_equal :small, reputation_token.level # Sanity
    assert_equal 2, reputation_token.value # Sanity

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:, merged_at:, reviews:
    )

    assert_equal 1, reviewer.reputation_tokens.size
    assert_equal :medium, reputation_token.reload.level
    assert_equal 5, reputation_token.reload.value
  end

  test "sets earned on date to pull request merged date when pull request is merged" do
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
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"
    create :github_organization_member, username: "reviewer71"
    create :github_organization_member, username: "reviewer13"
    reviews = [
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:,
      merged:, merged_at:, reviews:
    )

    reputation_token_1 = reviewer_1.reputation_tokens.last
    assert_equal merged_at.to_date, reputation_token_1.earned_on

    reputation_token_2 = reviewer_2.reputation_tokens.last
    assert_equal merged_at.to_date, reputation_token_2.earned_on
  end

  test "sets earned on date to pull request closed at date when pull request is closed" do
    action = 'closed'
    author = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
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
      { reviewer_username: "reviewer71" },
      { reviewer_username: "reviewer13" }
    ]

    User::ReputationToken::AwardForPullRequestReviewers.(
      action:, author_username: author, url:, html_url:, labels:,
      repo:, node_id:, number:, title:, merged:,
      closed_at:, reviews:
    )

    reputation_token_1 = reviewer_1.reputation_tokens.last
    assert_equal closed_at.to_date, reputation_token_1.earned_on

    reputation_token_2 = reviewer_2.reputation_tokens.last
    assert_equal closed_at.to_date, reputation_token_2.earned_on
  end
end
