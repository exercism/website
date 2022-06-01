require 'test_helper'

class Solution::UnpublishTest < ActiveSupport::TestCase
  test "unpublishes solution" do
    solution = create :concept_solution
    iteration = create :iteration, solution: solution
    iteration.solution.update!(published_iteration: iteration, published_at: Time.current)

    Solution::Unpublish.(solution)

    assert_nil solution.published_iteration
    assert_nil solution.published_at
  end

  test "solution snippet updated to latest active iteration's snippet" do
    solution = create :concept_solution
    iteration_1 = create :iteration, solution: solution, snippet: 'aaa'
    iteration_2 = create :iteration, solution: solution, snippet: 'bbb'
    iteration_1.solution.update!(published_iteration: iteration_1, published_at: Time.current, snippet: iteration_1.snippet)

    Solution::Unpublish.(solution)

    assert_equal iteration_2.snippet, solution.snippet
  end
end
