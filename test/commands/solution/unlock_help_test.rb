require "test_helper"

class Solution::UnlockHelpTest < ActiveSupport::TestCase
  test "unlocks help when solution has been downloaded" do
    solution = create :practice_solution, :downloaded

    # Sanity check
    refute solution.unlocked_help?

    Solution::UnlockHelp.(solution)

    assert solution.unlocked_help?
  end

  test "unlocks help when solution has been submitted" do
    solution = create :practice_solution
    create(:submission, solution:)

    # Sanity check
    refute solution.unlocked_help?

    Solution::UnlockHelp.(solution)

    assert solution.unlocked_help?
  end

  test "does not unlock help if solution has not been downloaded or submitted" do
    solution = create :practice_solution

    # Sanity check
    refute solution.unlocked_help?

    assert_raises SolutionCannotBeUnlockedError do
      Solution::UnlockHelp.(solution)
    end

    refute solution.unlocked_help?
  end
end
