require 'test_helper'

class Solution::UncompleteTest < ActiveSupport::TestCase
  test "unpublishes solution" do
    solution = create :concept_solution
    iteration = create :iteration, solution: solution
    iteration.solution.update!(published_iteration: iteration, published_at: Time.current)

    Solution::Unpublish.(solution)

    assert_nil solution.published_iteration
    assert_nil solution.published_at
  end
end
