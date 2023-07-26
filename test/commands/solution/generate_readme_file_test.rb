require 'test_helper'

class Solution::GenerateReadmeFileTest < ActiveSupport::TestCase
  test "generate for concept exercise" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    contents = Solution::GenerateReadmeFile.(solution)

    expected = "# Strings\n\nWelcome to Strings on Exercism's Ruby Track.\nIf you need help running the tests or submitting your code, check out `HELP.md`.\nIf you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)\n\n## Introduction\n\nA `String` in Ruby is an object that holds and manipulates an arbitrary sequence of bytes, typically representing characters. Strings are manipulated by calling the string's methods.\n\n## Instructions\n\nIn this exercise you'll be processing log-lines.\n\nEach log line is a string formatted as follows: `\"[<LEVEL>]: <MESSAGE>\"`.\n\nThere are three different log levels:\n\n- `INFO`\n- `WARNING`\n- `ERROR`\n\nYou have three tasks, each of which will take a log line and ask you to do something with it.\n\n## 1. Get message from a log line\n\nImplement the `LogLineParser.message` method to return a log line's message:\n\n```ruby\nLogLineParser.message('[ERROR]: Invalid operation')\n// Returns: \"Invalid operation\"\n```\n\nAny leading or trailing white space should be removed:\n\n```ruby\nLogLineParser.message('[WARNING]:  Disk almost full\\r\\n')\n// Returns: \"Disk almost full\"\n```\n\n## 2. Get log level from a log line\n\nImplement the `LogLineParser.log_level` method to return a log line's log level, which should be returned in lowercase:\n\n```ruby\nLogLineParser.log_level('[ERROR]: Invalid operation')\n// Returns: \"error\"\n```\n\n## 3. Reformat a log line\n\nImplement the `LogLineParser.reformat` method that reformats the log line, putting the message first and the log level after it in parentheses:\n\n```ruby\nLogLineParser.reformat('[INFO]: Operation completed')\n// Returns: \"Operation completed (info)\"\n```\n\n## Source\n\n### Created by\n\n- @pvcarrera" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "generate for practice exercise with hints" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)

    contents = Solution::GenerateReadmeFile.(solution)
    expected = "# Bob\n\nWelcome to Bob on Exercism's Ruby Track.\nIf you need help running the tests or submitting your code, check out `HELP.md`.\nIf you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)\n\n## Introduction\n\nIntroduction for bob\n\nExtra introduction for bob\n\n## Instructions\n\nInstructions for bob\n\nExtra instructions for bob\n\n## Source\n\n### Created by\n\n- @erikschierboom\n\n### Contributed to by\n\n- @ihid\n\n### Based on\n\nInspired by the 'Deaf Grandma' exercise in Chris Pine's Learn to Program tutorial. - http://pine.fm/LearnToProgram/?Chapter=06" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "generate for practice exercise without introduction" do
    exercise = create :practice_exercise, slug: 'anagram'
    solution = create(:practice_solution, exercise:)

    contents = Solution::GenerateReadmeFile.(solution)
    expected = "# Anagram\n\nWelcome to Anagram on Exercism's Ruby Track.\nIf you need help running the tests or submitting your code, check out `HELP.md`.\n\n## Instructions\n\nInstructions for the anagram exercise.\n\n## Source\n\n### Created by\n\n- @erikschierboom\n- @taiyab" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "generate for practice exercise without hints" do
    exercise = create :practice_exercise, slug: 'space-age'
    solution = create(:practice_solution, exercise:)

    contents = Solution::GenerateReadmeFile.(solution)
    expected = "# Space Age\n\nWelcome to Space Age on Exercism's Ruby Track.\nIf you need help running the tests or submitting your code, check out `HELP.md`.\n\n## Introduction\n\nIntroduction for space-age\n\n## Instructions\n\nInstructions for space-age\n\n## Source\n\n### Created by\n\n- @erikschierboom\n\n### Contributed to by\n\n- @ihid" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "generate for practice exercise without contributors" do
    exercise = create :practice_exercise, slug: 'allergies'
    solution = create(:practice_solution, exercise:)

    contents = Solution::GenerateReadmeFile.(solution)
    expected = "# Allergies\n\nWelcome to Allergies on Exercism's Ruby Track.\nIf you need help running the tests or submitting your code, check out `HELP.md`.\n\n## Instructions\n\nInstructions for allergies\n\n## Source\n\n### Created by\n\n- @erikschierboom" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "generate for practice exercise without source" do
    exercise = create :practice_exercise, slug: 'isogram'
    solution = create(:practice_solution, exercise:)

    contents = Solution::GenerateReadmeFile.(solution)
    expected = "# Isogram\n\nWelcome to Isogram on Exercism's Ruby Track.\nIf you need help running the tests or submitting your code, check out `HELP.md`.\n\n## Instructions\n\nInstructions for isogram" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end
end
