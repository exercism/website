require "test_helper"

class Github::PullRequestReviewTest < ActiveSupport::TestCase
  test "data" do
    review = create :github_pull_request_review

    assert_equal 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4', review.node_id
    assert_equal 'ErikSchierboom', review.reviewer_username
    assert_equal 'iHiD', review.pull_request.author_username
  end
end
