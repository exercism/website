require "test_helper"

class Solution::Comment::DestroyTest < ActiveSupport::TestCase
  test "destroys the comment and returns true" do
    comment = create :solution_comment

    assert Solution::Comment::Destroy.(comment)

    assert_empty Solution::Comment.where(id: comment.id)
  end

  test "decrements num_comments on solution" do
    solution = create :practice_solution
    comment = create(:solution_comment, solution:)
    assert_equal 1, solution.reload.num_comments

    Solution::Comment::Destroy.(comment)

    assert_equal 0, solution.reload.num_comments
  end

  test "invalidates the cloudflare cache" do
    solution = create :practice_solution
    comment = create(:solution_comment, solution:)

    Solution::InvalidateCloudflareCache.expects(:defer).with(solution)

    Solution::Comment::Destroy.(comment)
  end
end
