require "test_helper"

class Solution::PublishIterationTest < ActiveSupport::TestCase
  test "change published iteration" do
    solution = create :practice_solution
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2
    solution.update(published_iteration: other_iteration, published_at: Time.current)

    Solution::PublishIteration.(solution, 1)

    assert_equal iteration, solution.reload.published_iteration
    assert solution.reload.published?
    assert iteration.reload.published?
    refute other_iteration.reload.published?
  end
end
