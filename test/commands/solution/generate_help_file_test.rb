require 'test_helper'

class Solution::GenerateHelpFileTest < ActiveSupport::TestCase
  test "generate for concept exercise" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise

    contents = Solution::GenerateHelpFile.(solution)
    expected = "# Help\n\n## Running the tests\n\nRun the tests using `ruby test`.\n\n## Submitting your solution\n\nTODO\n\n## Need to get help?\n\nTODO\n\nStuck? Try the Ruby gitter channel." # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "generate for practice exercise" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise: exercise

    contents = Solution::GenerateHelpFile.(solution)
    expected = "# Help\n\n## Running the tests\n\nRun the tests using `ruby test`.\n\n## Submitting your solution\n\nTODO\n\n## Need to get help?\n\nTODO\n\nStuck? Try the Ruby gitter channel." # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end
end
