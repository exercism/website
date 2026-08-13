require "test_helper"

class Solution::Star::DestroyTest < ActiveSupport::TestCase
  test "unstars the solution" do
    user = create :user
    solution = create :practice_solution
    create(:solution_star, solution:, user:)

    Solution::Star::Destroy.(solution, user)

    assert_equal 0, solution.reload.num_stars
    assert_empty solution.stars
  end

  test "leaves other users' stars alone" do
    user = create :user
    other_user = create :user
    solution = create :practice_solution
    create(:solution_star, solution:, user:)
    other_star = create(:solution_star, solution:, user: other_user)

    Solution::Star::Destroy.(solution, user)

    assert_equal [other_star], solution.reload.stars
  end

  test "invalidates the cloudflare cache" do
    user = create :user
    solution = create :practice_solution
    create(:solution_star, solution:, user:)

    Solution::InvalidateCloudflareCache.expects(:defer).with(solution)

    Solution::Star::Destroy.(solution, user)
  end
end
