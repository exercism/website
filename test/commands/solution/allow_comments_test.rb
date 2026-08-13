require "test_helper"

class Solution::AllowCommentsTest < ActiveSupport::TestCase
  test "sets allow_comments to true" do
    solution = create :practice_solution, allow_comments: false

    Solution::AllowComments.(solution)

    assert solution.reload.allow_comments
  end

  test "invalidates the cloudflare cache" do
    solution = create :practice_solution, allow_comments: false

    Solution::InvalidateCloudflareCache.expects(:defer).with(solution)

    Solution::AllowComments.(solution)
  end
end
