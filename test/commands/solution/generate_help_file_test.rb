require 'test_helper'

class Solution::GenerateHelpFileTest < ActiveSupport::TestCase
  test "generate for concept exercise" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise

    contents = Solution::GenerateHelpFile.(solution)
    expected = <<~EXPECTED.strip
                  # Help
            #{'      '}
                  ## Running the tests
            #{'      '}
                  Run the tests using `ruby test`.
            #{'      '}
                  ## Submitting your solution
      #{'      '}
                  You can submit your solution using the `exercism submit log_line_parser.rb` command.
                  This command will upload your solution to the Exercism website and print the solution page's URL.
      #{'      '}
                  It's possible to submit an incomplete solution which allows you to:
      #{'      '}
                  - See how others have completed the exercise
                  - Request help from a mentor
      #{'      '}
                  ## Need to get help?
      #{'      '}
                  If you'd like help solving the exercise, check the following pages:
      #{'      '}
                  - [Installing Ruby locally](https://exercism.io/docs/tracks/ruby/installation/)
                  - [How to learn Ruby](https://exercism.io/docs/tracks/ruby/learning/)
                  - [Useful Ruby resources](https://exercism.io/docs/tracks/ruby/resources/)
                  - [Testing on the Ruby track](https://exercism.io/docs/tracks/ruby/tests/)
      #{'      '}
                  For more general, non-track specific help, check:
      #{'      '}
                  - [Exercism's support channel on gitter](https://gitter.im/exercism/support)
                  - The [Frequently Asked Questions](https://exercism.io/docs/faq) TODO: (Required) use correct link
      #{'      '}
                  Should those resources not suffice, you could submit your (incomplete) solution to request mentoring.
      #{'      '}
                  Stuck? Try the Ruby gitter channel.
    EXPECTED
    assert_equal expected, contents
  end

  test "generate for practice exercise" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise: exercise

    contents = Solution::GenerateHelpFile.(solution)
    expected = <<~EXPECTED.strip
                  # Help
            #{'      '}
                  ## Running the tests
            #{'      '}
                  Run the tests using `ruby test`.
            #{'      '}
                  ## Submitting your solution
      #{'      '}
                  You can submit your solution using the `exercism submit bob.rb` command.
                  This command will upload your solution to the Exercism website and print the solution page's URL.
      #{'      '}
                  It's possible to submit an incomplete solution which allows you to:
      #{'      '}
                  - See how others have completed the exercise
                  - Request help from a mentor
      #{'      '}
                  ## Need to get help?
      #{'      '}
                  If you'd like help solving the exercise, check the following pages:
      #{'      '}
                  - [Installing Ruby locally](https://exercism.io/docs/tracks/ruby/installation/)
                  - [How to learn Ruby](https://exercism.io/docs/tracks/ruby/learning/)
                  - [Useful Ruby resources](https://exercism.io/docs/tracks/ruby/resources/)
                  - [Testing on the Ruby track](https://exercism.io/docs/tracks/ruby/tests/)
      #{'      '}
                  For more general, non-track specific help, check:
      #{'      '}
                  - [Exercism's support channel on gitter](https://gitter.im/exercism/support)
                  - The [Frequently Asked Questions](https://exercism.io/docs/faq) TODO: (Required) use correct link
      #{'      '}
                  Should those resources not suffice, you could submit your (incomplete) solution to request mentoring.
      #{'      '}
                  Stuck? Try the Ruby gitter channel.
    EXPECTED
    assert_equal expected, contents
  end
end
