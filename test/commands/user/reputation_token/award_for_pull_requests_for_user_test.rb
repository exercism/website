require "test_helper"

class User::ReputationToken::AwardForPullRequestsForUserTest < ActiveSupport::TestCase
  test "awards reputation for authored pull requests" do
    user = create :user, handle: "User1", github_username: "iHiD"
    create :github_pull_request, :random, state: :closed, author_username: "iHiD"
    create :github_pull_request, :random, state: :closed, author_username: "ErikSchierboom"
    create :github_pull_request, :random, state: :merged, author_username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 2, User::ReputationTokens::CodeContributionToken.where(user:).size
  end

  test "award reputation for reviewed pull requests" do
    user = create :user, handle: "User1", github_username: "ErikSchierboom"
    review_1 = create :github_pull_request_review, :random, reviewer_username: "ErikSchierboom"
    review_1.pull_request.update(state: :closed)
    review_2 = create :github_pull_request_review, :random, reviewer_username: "ErikSchierboom"
    review_2.pull_request.update(state: :closed)
    review_3 = create :github_pull_request_review, :random, reviewer_username: "iHiD"
    review_3.pull_request.update(state: :closed)
    review_4 = create :github_pull_request_review, :random, reviewer_username: "ErikSchierboom"
    review_4.pull_request.update(state: :closed)
    create :github_organization_member, username: "ErikSchierboom"
    create :github_organization_member, username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 3, User::ReputationTokens::CodeReviewToken.where(user:).size
  end

  test "award reputation for merged pull requests" do
    user = create :user, handle: "User1", github_username: "ErikSchierboom"
    create :github_pull_request, :random, state: :merged, merged_by_username: "ErikSchierboom"
    create :github_pull_request, :random, state: :merged, merged_by_username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 1, User::ReputationTokens::CodeMergeToken.where(user:).size
  end

  test "don't award reputation for user without github_username" do
    user = create :user, handle: "User1"
    create :github_pull_request, :random, merged_by_username: "ErikSchierboom"
    create :github_pull_request, :random, merged_by_username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_empty User::ReputationTokens::CodeMergeToken.where(user:)
  end

  test "don't award reputation for open pull requests" do
    user = create :user, github_username: "user-1"
    create :github_pull_request, :random, state: :open, author_username: user.github_username
    create :github_pull_request, :random, state: :open, merged_by_username: user.github_username
    review_pr = create :github_pull_request, :random, state: :open
    create :github_pull_request_review, :random, reviewer_username: user.github_username, pull_request: review_pr

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    refute User::ReputationTokens::CodeContributionToken.where(user:).exists?
    refute User::ReputationTokens::CodeReviewToken.where(user:).exists?
    refute User::ReputationTokens::CodeMergeToken.where(user:).exists?
  end
end
