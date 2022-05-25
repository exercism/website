require 'test_helper'

class Solution::GenerateHelpFileTest < ActiveSupport::TestCase
  test "generate for concept exercise" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    contents = Solution::GenerateHelpFile.(solution)
    expected = <<~EXPECTED.strip
      # Help

      ## Running the tests

      Run the tests using `ruby test`.

      ## Submitting your solution

      You can submit your solution using the `exercism submit log_line_parser.rb` command.
      This command will upload your solution to the Exercism website and print the solution page's URL.

      It's possible to submit an incomplete solution which allows you to:

      - See how others have completed the exercise
      - Request help from a mentor

      ## Need to get help?

      If you'd like help solving the exercise, check the following pages:

      - The [Ruby track's documentation](https://exercism.org/docs/tracks/ruby)
      - The [Ruby track's programming category on the forum](https://forum.exercism.org/c/programming/ruby)
      - [Exercism's programming category on the forum](https://forum.exercism.org/c/programming/5)
      - The [Frequently Asked Questions](https://exercism.org/docs/using/faqs)

      Should those resources not suffice, you could submit your (incomplete) solution to request mentoring.

      Stuck? Try the Ruby gitter channel.
    EXPECTED
    assert_equal expected, contents
  end

  test "generate for practice exercise" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)

    contents = Solution::GenerateHelpFile.(solution)
    expected = <<~EXPECTED.strip
      # Help

      ## Running the tests

      Run the tests using `ruby test`.

      ## Submitting your solution

      You can submit your solution using the `exercism submit bob.rb` command.
      This command will upload your solution to the Exercism website and print the solution page's URL.

      It's possible to submit an incomplete solution which allows you to:

      - See how others have completed the exercise
      - Request help from a mentor

      ## Need to get help?

      If you'd like help solving the exercise, check the following pages:

      - The [Ruby track's documentation](https://exercism.org/docs/tracks/ruby)
      - The [Ruby track's programming category on the forum](https://forum.exercism.org/c/programming/ruby)
      - [Exercism's programming category on the forum](https://forum.exercism.org/c/programming/5)
      - The [Frequently Asked Questions](https://exercism.org/docs/using/faqs)

      Should those resources not suffice, you could submit your (incomplete) solution to request mentoring.

      Stuck? Try the Ruby gitter channel.
    EXPECTED
    assert_equal expected, contents
  end

  test "generate for exercise with multiple solution files" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)
    Git::Exercise.any_instance.stubs(:solution_filepaths).returns(['bob.rb', 'lib.rb'])

    contents = Solution::GenerateHelpFile.(solution)
    expected = <<~EXPECTED.strip
      # Help

      ## Running the tests

      Run the tests using `ruby test`.

      ## Submitting your solution

      You can submit your solution using the `exercism submit bob.rb lib.rb` command.
      This command will upload your solution to the Exercism website and print the solution page's URL.

      It's possible to submit an incomplete solution which allows you to:

      - See how others have completed the exercise
      - Request help from a mentor

      ## Need to get help?

      If you'd like help solving the exercise, check the following pages:

      - The [Ruby track's documentation](https://exercism.org/docs/tracks/ruby)
      - The [Ruby track's programming category on the forum](https://forum.exercism.org/c/programming/ruby)
      - [Exercism's programming category on the forum](https://forum.exercism.org/c/programming/5)
      - The [Frequently Asked Questions](https://exercism.org/docs/using/faqs)

      Should those resources not suffice, you could submit your (incomplete) solution to request mentoring.

      Stuck? Try the Ruby gitter channel.
    EXPECTED
    assert_equal expected, contents
  end
end
