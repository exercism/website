require 'test_helper'

class Solution::GenerateHelpFileTest < ActiveSupport::TestCase
  test "generate for concept exercise" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise

    contents = Solution::GenerateHelpFile.(solution)
    expected = "# Help\n\n## Running the tests\n\nRun the tests using `ruby test`.\n\n## Submitting your solution\n\nYou can submit your solution using the `exercism submit log_line_parser.rb` command.\nThis command will upload your solution to the Exercism website and print the solution page's URL.\n\nIt's possible to submit an incomplete solution which allows you to:\n\n- See how others have completed the exercise\n- Request help from a mentor\n\n## Need to get help?\n\nIf you'd like help solving the exercise, check the following pages:\n\n- [Installing Ruby locally](https://exercism.io/docs/tracks/ruby/installation/)\n- [How to learn Ruby](https://exercism.io/docs/tracks/ruby/learning/)\n- [Useful Ruby resources](https://exercism.io/docs/tracks/ruby/resources/)\n- [Testing on the Ruby track](https://exercism.io/docs/tracks/ruby/tests/)\n\nFor more general, non-track specific help, check:\n\n- [Exercism's support channel on gitter](https://gitter.im/exercism/support)\n- The [Frequently Asked Questions](https://exercism.io/docs/faq) TODO: (Required) use correct link\n\nShould those resources not suffice, you could submit your (incomplete) solution to request mentoring.\n\nStuck? Try the Ruby gitter channel." # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "generate for practice exercise" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise: exercise

    contents = Solution::GenerateHelpFile.(solution)
    expected = "# Help\n\n## Running the tests\n\nRun the tests using `ruby test`.\n\n## Submitting your solution\n\nYou can submit your solution using the `exercism submit bob.rb` command.\nThis command will upload your solution to the Exercism website and print the solution page's URL.\n\nIt's possible to submit an incomplete solution which allows you to:\n\n- See how others have completed the exercise\n- Request help from a mentor\n\n## Need to get help?\n\nIf you'd like help solving the exercise, check the following pages:\n\n- [Installing Ruby locally](https://exercism.io/docs/tracks/ruby/installation/)\n- [How to learn Ruby](https://exercism.io/docs/tracks/ruby/learning/)\n- [Useful Ruby resources](https://exercism.io/docs/tracks/ruby/resources/)\n- [Testing on the Ruby track](https://exercism.io/docs/tracks/ruby/tests/)\n\nFor more general, non-track specific help, check:\n\n- [Exercism's support channel on gitter](https://gitter.im/exercism/support)\n- The [Frequently Asked Questions](https://exercism.io/docs/faq) TODO: (Required) use correct link\n\nShould those resources not suffice, you could submit your (incomplete) solution to request mentoring.\n\nStuck? Try the Ruby gitter channel." # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end
end
