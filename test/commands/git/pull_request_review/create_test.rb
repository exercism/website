require "test_helper"

class Git::PullRequestReview::CreateTest < ActiveSupport::TestCase
  test "create pull request review" do
    pr = create :git_pull_request
    node_id = "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4"
    reviewer = "ErikSchierboom"

    review = Git::PullRequestReview::Create.(pr, node_id, reviewer_github_username: reviewer)

    assert_equal pr, review.pull_request
    assert_equal "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4", review.node_id
    assert_equal "ErikSchierboom", review.reviewer_github_username
  end
end
