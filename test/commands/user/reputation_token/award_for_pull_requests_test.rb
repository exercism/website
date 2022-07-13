require "test_helper"

class User::ReputationToken::AwardForPullRequestsTest < ActiveSupport::TestCase
  test "awards reputation for all authored pull requests" do
    user_1 = create :user, handle: "User1", github_username: "user-1"
    user_2 = create :user, handle: "User2", github_username: "user-2"
    create :github_pull_request, :random, author_username: "user-1"
    create :github_pull_request, :random, author_username: "user-2"
    create :github_pull_request, :random, author_username: "user-1"

    assert_enqueued_jobs 3 do
      User::ReputationToken::AwardForPullRequests.()
    end

    perform_enqueued_jobs

    assert_equal 2, User::ReputationTokens::CodeContributionToken.where(user: user_1).size
    assert_equal 1, User::ReputationTokens::CodeContributionToken.where(user: user_2).size
  end

  test "award reputation for all reviewed pull requests" do
    user_1 = create :user, handle: "User1", github_username: "user-1"
    user_2 = create :user, handle: "User2", github_username: "user-2"
    create :github_pull_request_review, :random, reviewer_username: "user-2"
    create :github_pull_request_review, :random, reviewer_username: "user-2"
    create :github_pull_request_review, :random, reviewer_username: "user-1"
    create :github_pull_request_review, :random, reviewer_username: "user-2"
    create :github_organization_member, username: "user-1"
    create :github_organization_member, username: "user-2"

    assert_enqueued_jobs 4 do
      User::ReputationToken::AwardForPullRequests.()
    end

    perform_enqueued_jobs

    assert_equal 1, User::ReputationTokens::CodeReviewToken.where(user: user_1).size
    assert_equal 3, User::ReputationTokens::CodeReviewToken.where(user: user_2).size
  end

  test "award reputation for all merged pull requests" do
    user_1 = create :user, handle: "User1", github_username: "user-1"
    user_2 = create :user, handle: "User2", github_username: "user-2"
    create :github_pull_request, :random, merged_by_username: "user-2"
    create :github_pull_request, :random, merged_by_username: "user-1"

    assert_enqueued_jobs 2 do
      User::ReputationToken::AwardForPullRequests.()
    end

    perform_enqueued_jobs

    assert_equal 1, User::ReputationTokens::CodeMergeToken.where(user: user_1).size
    assert_equal 1, User::ReputationTokens::CodeMergeToken.where(user: user_2).size
  end

  test "award reputation for authoring, merging and reviewing pull requests at the same time" do
    create :user, handle: "User1", github_username: "user-1"
    create :user, handle: "User2", github_username: "user-2"
    create :github_pull_request, :random, author_username: "user-1"
    create :github_pull_request, :random, author_username: "user-2"
    create :github_pull_request, :random, author_username: "user-1"
    create :github_pull_request, :random, merged_by_username: "user-2"
    create :github_pull_request, :random, merged_by_username: "user-1"
    create :github_pull_request_review, :random, reviewer_username: "user-2"
    create :github_pull_request_review, :random, reviewer_username: "user-2"
    create :github_pull_request_review, :random, reviewer_username: "user-1"
    create :github_pull_request_review, :random, reviewer_username: "user-2"
    create :github_organization_member, username: "user-1"
    create :github_organization_member, username: "user-2"

    assert_enqueued_jobs 9 do
      User::ReputationToken::AwardForPullRequests.()
    end

    perform_enqueued_jobs

    assert_equal 3, User::ReputationTokens::CodeContributionToken.find_each.size
    assert_equal 2, User::ReputationTokens::CodeMergeToken.find_each.size
    assert_equal 4, User::ReputationTokens::CodeReviewToken.find_each.size
  end

  test "don't award reputation for open pull requests" do
    user = create :user, github_username: "user-1"
    create :github_pull_request, :random, state: :open, author_username: user.github_username
    create :github_pull_request, :random, state: :open, merged_by_username: user.github_username
    create :github_pull_request_review, :random, state: :open, reviewer_username: user.github_username

    perform_enqueued_jobs do
      User::ReputationToken::AwardForPullRequests.()
    end

    refute User::ReputationTokens::CodeContributionToken.exists?
    refute User::ReputationTokens::CodeReviewToken.exists?
    refute User::ReputationTokens::CodeMergeToken.exists?
  end
end
