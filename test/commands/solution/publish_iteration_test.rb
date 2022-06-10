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
    new_published_iteration = create :iteration, solution: solution, idx: 1, num_loc: 5
    old_published_iteration = create :iteration, solution: solution, idx: 2, num_loc: 14
    solution.update(published_iteration: old_published_iteration, published_at: Time.current)

    Solution::PublishIteration.(solution, 1)

    assert_equal new_published_iteration.num_loc, solution.num_loc
  end

  test "set solution loc to latest iteration loc if publishing all iterations" do
    solution = create :practice_solution, num_loc: 2
    iteration = create :iteration, solution: solution, idx: 1, num_loc: 5
    latest_iteration = create :iteration, solution: solution, idx: 2, num_loc: 14
    create :iteration, solution: solution, idx: 3, deleted_at: Time.current, num_loc: 7 # Last iteration
    solution.update(published_iteration: iteration, published_at: Time.current)

    Solution::PublishIteration.(solution, nil)

    assert_equal latest_iteration.num_loc, solution.num_loc
  end

  test "set solution snippet to published iteration's snippet when single iteration is published" do
    solution = create :practice_solution, snippet: 'my snippet', published_at: Time.current
    iteration = create :iteration, solution: solution, idx: 1, snippet: 'aaa'
    create :iteration, solution: solution, idx: 2, snippet: 'bbb'

    Solution::PublishIteration.(solution, 1)

    assert_equal iteration.snippet, solution.snippet
  end

  test "set solution snippet updated to latest published iteration's snippet when all iterations are published" do
    solution = create :practice_solution, snippet: 'my snippet', published_at: Time.current
    create :iteration, solution: solution, idx: 1, snippet: 'aaa'
    other_iteration = create :iteration, solution: solution, idx: 2, snippet: 'bbb'

    Solution::PublishIteration.(solution, nil)

    assert_equal other_iteration.snippet, solution.snippet
  end
end
