require 'test_helper'

class Solution::GenerateHintsFileTest < ActiveSupport::TestCase
  test "generate for concept exercise" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    contents = Solution::GenerateHintsFile.(solution)
    expected = "# Hints\n\n## General\n\n- The [rubymostas strings guide][ruby-for-beginners.rubymonstas.org-strings] has a nice introduction to Ruby strings.\n- The `String` object has many useful [built-in methods][docs-string-methods].\n\n## 1. Get message from a log line\n\n- There are different ways to search for text in a string, which can be found on the [Ruby language official documentation][docs-string-methods].\n- There are [built in methods][strip-white-space] to strip white space.\n\n## 2. Get log level from a log line\n\n- Ruby `String` objects have a [method][downcase] to perform this operation.\n\n## 3. Reformat a log line\n\n- There are several ways to [concatenate strings][ruby-for-beginners.rubymonstas.org-strings], but the preferred one is usually [string interpolation][ruby-for-beginners.rubymonstas.org-strings]\n\n[ruby-for-beginners.rubymonstas.org-strings]: http://ruby-for-beginners.rubymonstas.org/built_in_classes/strings.html\n[ruby-for-beginners.rubymonstas.org-interpolation]: http://ruby-for-beginners.rubymonstas.org/bonus/string_interpolation.html\n[docs-string-methods]: https://ruby-doc.org/core-2.7.0/String.html\n[strip-white-space]: https://ruby-doc.org/core-2.7.0/String.html#method-i-strip\n[downcase]: https://ruby-doc.org/core-2.7.0/String.html#method-i-downcase" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "generate for practice exercise" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)

    contents = Solution::GenerateHintsFile.(solution)
    expected = "# Hints\n\n## General\n\n- There are many useful string methods built-in"
    assert_equal expected, contents
  end
end
