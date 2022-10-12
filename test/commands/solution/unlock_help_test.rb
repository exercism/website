require "test_helper"

class Solution::UnlockHelpTest < ActiveSupport::TestCase
  test "unlocks help" do
    solution = create :practice_solution
    create :iteration, solution: solution

    # Sanity check
    refute solution.unlocked_help?

    Solution::UnlockHelp.(solution)

    assert solution.unlocked_help?
  end

  test "does not unlock help if solution has no iterations" do
    solution = create :practice_solution

    # Sanity check
    refute solution.unlocked_help?

    assert_raises SolutionHasNoIterationsError do
      Solution::UnlockHelp.(solution)
    end

    refute solution.unlocked_help?
  end
end
