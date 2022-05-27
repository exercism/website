require 'test_helper'

class Solution::UpdateSnippetTest < ActiveSupport::TestCase
  test "remove snippet when there are only deleted iterations" do
    solution = create :concept_solution, snippet: 'my snippet'
    create :iteration, :deleted, solution: solution, snippet: 'aaa'
    create :iteration, :deleted, solution: solution, snippet: 'bbb'
    create :iteration, :deleted, solution: solution, snippet: 'ccc'

    Solution::UpdateSnippet.(solution)

    assert_nil solution.snippet
  end

  test "update snippet to published solution's single published iteration's snippet" do
    solution = create :concept_solution, snippet: 'my snippet'
    create :iteration, solution: solution, snippet: 'aaa'
    create :iteration, solution: solution, snippet: 'bbb'
    iteration = create :iteration, solution: solution, snippet: 'ccc'
    solution.update(published_at: Time.current, published_iteration: iteration)

    Solution::UpdateSnippet.(solution)

    assert_equal iteration.snippet, solution.snippet
  end

  test "update snippet to published solution's newest active iteration's snippet" do
    solution = create :concept_solution, snippet: 'my snippet'
    create :iteration, solution: solution, snippet: 'aaa'
    iteration = create :iteration, solution: solution, snippet: 'bbb'
    create :iteration, :deleted, solution: solution, snippet: 'ccc'
    solution.update(published_at: Time.current)

    Solution::UpdateSnippet.(solution)

    assert_equal iteration.snippet, solution.snippet
  end
end
