require "test_helper"

class Solution::DisallowCommentsTest < ActiveSupport::TestCase
  test "sets allow_comments to false" do
    solution = create :practice_solution, allow_comments: true

    Solution::DisallowComments.(solution)

    refute solution.reload.allow_comments
  end

  test "invalidates the cloudflare cache" do
    solution = create :practice_solution, allow_comments: true

    Solution::InvalidateCloudflareCache.expects(:defer).with(solution)

    Solution::DisallowComments.(solution)
  end
end
