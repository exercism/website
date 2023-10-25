require 'test_helper'

class Solution::UpdateNumLocTest < ActiveSupport::TestCase
  test "set solution num_loc to latest published iteration's num_loc when present" do
    solution = create :concept_solution, num_loc: 0
    published_iteration = create :iteration, solution:, num_loc: 5
    solution.update(published_iteration:, published_at: Time.current)
    create :iteration, solution:, num_loc: 7

    Solution::UpdateNumLoc.(solution)

    assert_equal published_iteration.num_loc, solution.num_loc
  end

  test "set solution num_loc to latest iteration's num_loc when no iterations are published" do
    solution = create :concept_solution, num_loc: 0
    create :iteration, solution:, num_loc: 5
    last_iteration = create :iteration, solution:, num_loc: 8
    solution.update(published_iteration: nil, published_at: nil)

    Solution::UpdateNumLoc.(solution)

    assert_equal last_iteration.num_loc, solution.num_loc
  end

  test "set solution num_loc to 0 when there are no active iterations" do
    solution = create :concept_solution, num_loc: 0
    create :iteration, :deleted, solution:, num_loc: 5
    create :iteration, :deleted, solution:, num_loc: 8
    solution.update(published_iteration: nil, published_at: nil)

    Solution::UpdateNumLoc.(solution)

    assert_equal 0, solution.num_loc
  end
end
