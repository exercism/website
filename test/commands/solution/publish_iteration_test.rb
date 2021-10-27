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

  test "set solution loc to published iteration loc" do
    solution = create :practice_solution, num_loc: 14
    iteration = create :iteration, solution: solution, idx: 1, num_loc: 5
    other_iteration = create :iteration, solution: solution, idx: 2, num_loc: 14
    solution.update(published_iteration: other_iteration, published_at: Time.current)

    Solution::PublishIteration.(solution, 1)

    assert_equal iteration.num_loc, solution.num_loc
  end

  test "set solution loc to last iteration loc if publishing all iterations" do
    solution = create :practice_solution, num_loc: 2
    iteration = create :iteration, solution: solution, idx: 1, num_loc: 5
    other_iteration = create :iteration, solution: solution, idx: 2, num_loc: 14
    solution.update(published_iteration: iteration, published_at: Time.current)

    Solution::PublishIteration.(solution, nil)

    assert_equal other_iteration.num_loc, solution.num_loc
  end
end
