require "test_helper"

class Git::PullRequestReview::CreateOrUpdateTest < ActiveSupport::TestCase
  test "create pull request review" do
    pr = create :git_pull_request
    node_id = "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4"
    reviewer = "ErikSchierboom"

    review = Git::PullRequestReview::CreateOrUpdate.(pr, node_id, reviewer_github_username: reviewer)

    assert_equal pr, review.pull_request
    assert_equal "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4", review.node_id
    assert_equal "ErikSchierboom", review.reviewer_github_username
  end

  test "update pull request review if reviewer has changed" do
    review = create :git_pull_request_review
    new_reviewer = "new-reviewer"

    review = Git::PullRequestReview::CreateOrUpdate.(review.pull_request, review.node_id,
      reviewer_github_username: new_reviewer)

    assert_equal "new-reviewer", review.reviewer_github_username
  end
end
