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
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, slug: 'log-levels'

    serialized = SerializeExerciseInstructions.(exercise)

    expected = "<p>In this exercise you'll be processing log-lines.</p>
<p>Each log line is a string formatted as follows: <code>&quot;[&lt;LEVEL&gt;]: &lt;MESSAGE&gt;&quot;</code>.</p>
<p>There are three different log levels:</p>
<ul>
<li><code>INFO</code></li>
<li><code>WARNING</code></li>
<li><code>ERROR</code></li>
</ul>
<p>You have three tasks, each of which will take a log line and ask you to do something with it.</p>
"
    assert_equal expected, serialized[:overview]
  end
end
