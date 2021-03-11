require "test_helper"

class User::ReputationToken::AwardForPullRequestsForUserTest < ActiveSupport::TestCase
  test "awards reputation for authored pull requests" do
    user = create :user, handle: "User1", github_username: "iHiD"
    create :git_pull_request, :random, author_github_username: "iHiD"
    create :git_pull_request, :random, author_github_username: "ErikSchierboom"
    create :git_pull_request, :random, author_github_username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 2, User::ReputationTokens::CodeContributionToken.where(user: user).size
  end

  test "award reputation for reviewed pull requests" do
    user = create :user, handle: "User1", github_username: "ErikSchierboom"
    create :git_pull_request_review, :random, reviewer_github_username: "ErikSchierboom"
    create :git_pull_request_review, :random, reviewer_github_username: "ErikSchierboom"
    create :git_pull_request_review, :random, reviewer_github_username: "iHiD"
    create :git_pull_request_review, :random, reviewer_github_username: "ErikSchierboom"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 3, User::ReputationTokens::CodeReviewToken.where(user: user).size
  end

  test "award reputation for merged pull requests" do
    user = create :user, handle: "User1", github_username: "ErikSchierboom"
    create :git_pull_request, :random, merged_by_github_username: "ErikSchierboom"
    create :git_pull_request, :random, merged_by_github_username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 1, User::ReputationTokens::CodeMergeToken.where(user: user).size
  end
end
