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

  test "serialize task titles" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, slug: 'log-levels'

    serialized = SerializeExerciseInstructions.(exercise)

    expected = ['Get message from a log line', 'Get log level from a log line', 'Reformat a log line']
    assert_equal expected, (serialized[:tasks].map { |task| task[:title] })
  end

  test "serialize task text" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, slug: 'log-levels'

    serialized = SerializeExerciseInstructions.(exercise)

    expected = [
      "<p>Implement the <code>message</code> function to return a log line's message:</p>\n<pre><code class=\"language-fsharp\">message &quot;[ERROR]: Invalid operation&quot;\n// =&gt; &quot;Invalid operation&quot;\n</code></pre>\n<p>Any leading or trailing white space should be removed:</p>\n<pre><code class=\"language-fsharp\">message &quot;[WARNING]:  Disk almost full\\r\\n&quot;\n// =&gt; &quot;Disk almost full&quot;\n</code></pre>", # rubocop:disable Layout/LineLength
      "<p>Implement the <code>logLevel</code> function to return a log line's log level, which should be returned in lowercase:</p>\n<pre><code class=\"language-fsharp\">logLevel &quot;[ERROR]: Invalid operation&quot;\n// =&gt; &quot;error&quot;\n</code></pre>", # rubocop:disable Layout/LineLength
      "<p>Implement the <code>reformat</code> function that reformats the log line, putting the message first and the log level after it in parentheses:</p>\n<pre><code class=\"language-fsharp\">reformat &quot;[INFO]: Operation completed&quot;\n// =&gt; &quot;Operation completed (info)&quot;\n</code></pre>" # rubocop:disable Layout/LineLength
    ]
    assert_equal expected, (serialized[:tasks].map { |task| task[:text] })
  end
end
