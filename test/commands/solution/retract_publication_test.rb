require "test_helper"

class Solution::RetractPublicationTest < ActiveSupport::TestCase
  test "unpublishes the solution" do
    solution = create :practice_solution, :published

    Solution::RetractPublication.(solution)

    solution.reload
    assert_nil solution.published_at
    assert_nil solution.published_iteration_id
    refute solution.published?
  end

  test "invalidates the cloudflare cache" do
    solution = create :practice_solution, :published

    Solution::InvalidateCloudflareCache.expects(:defer).with(solution)

    Solution::RetractPublication.(solution)
  end
end
