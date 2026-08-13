require "test_helper"

class Solution::Star::CreateTest < ActiveSupport::TestCase
  test "stars the solution" do
    user = create :user
    solution = create :practice_solution

    star = Solution::Star::Create.(solution, user)

    assert_equal user, star.user
    assert_equal solution, star.solution
    assert_equal 1, solution.reload.num_stars
  end

  test "is idempotent" do
    user = create :user
    solution = create :practice_solution

    first = Solution::Star::Create.(solution, user)
    second = Solution::Star::Create.(solution, user)

    assert_equal first, second
    assert_equal 1, solution.reload.num_stars
  end

  test "invalidates the cloudflare cache" do
    user = create :user
    solution = create :practice_solution

    Solution::InvalidateCloudflareCache.expects(:defer).with(solution)

    Solution::Star::Create.(solution, user)
  end
end
