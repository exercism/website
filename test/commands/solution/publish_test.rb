require "test_helper"

class Solution::CompleteTest < ActiveSupport::TestCase
  test "sets solution and iteration as published" do
    solution = create :practice_solution
    iteration = create :iteration, solution: solution

    Solution::Publish.(solution, [iteration.idx])

    assert solution.reload.published?
    assert iteration.reload.published?
  end

  test "sets correct iterations as published" do
    solution = create :practice_solution
    iteration_1 = create :iteration, solution: solution
    iteration_2 = create :iteration, solution: solution
    iteration_3 = create :iteration, solution: solution

    Solution::Publish.(solution, [iteration_1.idx, iteration_3.idx])

    assert solution.reload.published?
    assert iteration_1.reload.published?
    refute iteration_2.reload.published?
    assert iteration_3.reload.published?
  end

  test "defaults to last iteration with no iterations" do
    solution = create :practice_solution
    iteration_1 = create :iteration, solution: solution
    iteration_2 = create :iteration, solution: solution
    iteration_3 = create :iteration, solution: solution

    Solution::Publish.(solution, [])

    assert solution.reload.published?
    refute iteration_1.reload.published?
    refute iteration_2.reload.published?
    assert iteration_3.reload.published?
  end

  test "defaults to last iteration with incorrect iterations" do
    solution = create :practice_solution
    iteration_1 = create :iteration, solution: solution
    iteration_2 = create :iteration, solution: solution
    iteration_3 = create :iteration, solution: solution

    Solution::Publish.(solution, [5])

    assert solution.reload.published?
    refute iteration_1.reload.published?
    refute iteration_2.reload.published?
    assert iteration_3.reload.published?
  end
end
