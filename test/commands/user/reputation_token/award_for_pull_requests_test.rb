require "test_helper"

class User::ReputationToken::AwardForPullRequestsForUserTest < ActiveSupport::TestCase
  test "awards reputation for authored pull requests" do
    user_1 = create :user, handle: "User1", github_username: "user-1"
    user_2 = create :user, handle: "User2", github_username: "user-2"
    create :git_pull_request, :random, author_github_username: "user-1"
    create :git_pull_request, :random, author_github_username: "user-2"
    create :git_pull_request, :random, author_github_username: "user-1"

    User::ReputationToken::AwardForPullRequests.()

    assert_equal 2, User::ReputationTokens::CodeContributionToken.where(user: user_1).size
    assert_equal 1, User::ReputationTokens::CodeContributionToken.where(user: user_2).size
  end

  test "award reputation for reviewed pull requests" do
    user_1 = create :user, handle: "User1", github_username: "user-1"
    user_2 = create :user, handle: "User2", github_username: "user-2"
    create :git_pull_request_review, :random, reviewer_github_username: "user-2"
    create :git_pull_request_review, :random, reviewer_github_username: "user-2"
    create :git_pull_request_review, :random, reviewer_github_username: "user-1"
    create :git_pull_request_review, :random, reviewer_github_username: "user-2"

    User::ReputationToken::AwardForPullRequests.()

    assert_equal 1, User::ReputationTokens::CodeReviewToken.where(user: user_1).size
    assert_equal 3, User::ReputationTokens::CodeReviewToken.where(user: user_2).size
  end

  test "award reputation for merged pull requests" do
    user_1 = create :user, handle: "User1", github_username: "user-1"
    user_2 = create :user, handle: "User2", github_username: "user-2"
    create :git_pull_request, :random, merged_by_github_username: "user-2"
    create :git_pull_request, :random, merged_by_github_username: "user-1"

    User::ReputationToken::AwardForPullRequests.()

    assert_equal 1, User::ReputationTokens::CodeMergeToken.where(user: user_1).size
    assert_equal 1, User::ReputationTokens::CodeMergeToken.where(user: user_2).size
  end

  test "award reputation for authoring, merging and reviewing pull requests" do
    create :user, handle: "User1", github_username: "user-1"
    create :user, handle: "User2", github_username: "user-2"
    create :git_pull_request, :random, author_github_username: "user-1"
    create :git_pull_request, :random, author_github_username: "user-2"
    create :git_pull_request, :random, author_github_username: "user-1"
    create :git_pull_request, :random, merged_by_github_username: "user-2"
    create :git_pull_request, :random, merged_by_github_username: "user-1"
    create :git_pull_request_review, :random, reviewer_github_username: "user-2"
    create :git_pull_request_review, :random, reviewer_github_username: "user-2"
    create :git_pull_request_review, :random, reviewer_github_username: "user-1"
    create :git_pull_request_review, :random, reviewer_github_username: "user-2"

    User::ReputationToken::AwardForPullRequests.()

    assert_equal 3, User::ReputationTokens::CodeContributionToken.find_each.size
    assert_equal 2, User::ReputationTokens::CodeMergeToken.find_each.size
    assert_equal 4, User::ReputationTokens::CodeReviewToken.find_each.size
  end
end
