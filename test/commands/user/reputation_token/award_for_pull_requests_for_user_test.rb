require "test_helper"

class User::ReputationToken::AwardForPullRequestsForUserTest < ActiveSupport::TestCase
  test "awards reputation for authored pull requests" do
    user = create :user, handle: "User1", github_username: "iHiD"
    create :github_pull_request, :random, author_username: "iHiD"
    create :github_pull_request, :random, author_username: "ErikSchierboom"
    create :github_pull_request, :random, author_username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 2, User::ReputationTokens::CodeContributionToken.where(user:).size
  end

  test "award reputation for reviewed pull requests" do
    user = create :user, handle: "User1", github_username: "ErikSchierboom"
    create :github_pull_request_review, :random, reviewer_username: "ErikSchierboom"
    create :github_pull_request_review, :random, reviewer_username: "ErikSchierboom"
    create :github_pull_request_review, :random, reviewer_username: "iHiD"
    create :github_pull_request_review, :random, reviewer_username: "ErikSchierboom"
    create :github_organization_member, username: "ErikSchierboom"
    create :github_organization_member, username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 3, User::ReputationTokens::CodeReviewToken.where(user:).size
  end

  test "award reputation for merged pull requests" do
    user = create :user, handle: "User1", github_username: "ErikSchierboom"
    create :github_pull_request, :random, merged_by_username: "ErikSchierboom"
    create :github_pull_request, :random, merged_by_username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 1, User::ReputationTokens::CodeMergeToken.where(user:).size
  end

  test "don't award reputation for user without github_username" do
    user = create :user, handle: "User1"
    create :github_pull_request, :random, merged_by_username: "ErikSchierboom"
    create :github_pull_request, :random, merged_by_username: "iHiD"

    User::ReputationToken::AwardForPullRequestsForUser.(user)

    assert_equal 0, User::ReputationTokens::CodeMergeToken.where(user:).size
  end
end
