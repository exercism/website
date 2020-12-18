require 'test_helper'

class SerializeExerciseInstructionsTest < ActiveSupport::TestCase
  test "serialize general hints" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, slug: 'log-levels'

    serialized = SerializeExerciseInstructions.(exercise)

    expected = [
      "The <code>string</code> class has many useful <a href=\"https://docs.microsoft.com/en-us/dotnet/api/system.string?view=netcore-3.1#methods\">built-in methods</a>.", # rubocop:disable Layout/LineLength
      "Remember that strings are immutable."
    ]
    assert_equal expected, serialized[:general_hints]
  end

  test "serialize overview" do
    skip
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, slug: 'log-levels'

    serialized = SerializeExerciseInstructions.(exercise)

    expected = "In this exercise you'll be processing log-lines.

Each log line is a string formatted as follows: `\"[<LEVEL>]: <MESSAGE>\"`.

There are three different log levels:

- `INFO`
- `WARNING`
- `ERROR`

You have three tasks, each of which will take a log line and ask you to do something with it."
    assert_equal expected, serialized[:overview]
  end
end
