require 'test_helper'

class Solution::UncompleteTest < ActiveSupport::TestCase
  test "unpublishes solution" do
    solution = create :concept_solution
    iteration = create(:iteration, solution:)
    iteration.solution.update!(completed_at: Time.current, published_iteration: iteration, published_at: Time.current)

    Solution::Uncomplete.(solution)

    assert_nil solution.published_iteration
    assert_nil solution.published_at
  end

  test "uncompletes solution" do
    solution = create :concept_solution
    iteration = create(:iteration, solution:)
    iteration.solution.update!(completed_at: Time.current, published_iteration: iteration, published_at: Time.current)

    Solution::Uncomplete.(solution)

    refute solution.completed?
    assert_nil solution.completed_at
  end
end
