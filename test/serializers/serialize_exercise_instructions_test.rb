require 'test_helper'

class SerializeExerciseInstructionsTest < ActiveSupport::TestCase
  test "serialize general hints" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, slug: 'log-levels'

    serialized = SerializeExerciseInstructions.(exercise)

    expected = [
      "<p>The <code>string</code> class has many useful <a href=\"https://docs.microsoft.com/en-us/dotnet/api/system.string?view=netcore-3.1#methods\" target=\"_blank\">built-in\nmethods</a>.</p>\n", # rubocop:disable Layout/LineLength
      "<p>Remember that strings are immutable.</p>\n"
    ]
    assert_equal expected, serialized[:general_hints]
  end

  test "serialize overview" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, slug: 'log-levels'

    serialized = SerializeExerciseInstructions.(exercise)

    expected = "<p>In this exercise you'll be processing log-lines.</p>
<p>Each log line is a string formatted as follows: <code>\"[&lt;LEVEL&gt;]: &lt;MESSAGE&gt;\"</code>.</p>
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
      "<p>Implement the <code>message</code> function to return a log line's message:</p>\n<pre><code class=\"language-fsharp\">message \"[ERROR]: Invalid operation\"\n// =&gt; \"Invalid operation\"\n</code></pre>\n<p>Any leading or trailing white space should be removed:</p>\n<pre><code class=\"language-fsharp\">message \"[WARNING]:  Disk almost full\\r\\n\"\n// =&gt; \"Disk almost full\"\n</code></pre>\n", # rubocop:disable Layout/LineLength
      "<p>Implement the <code>logLevel</code> function to return a log line's log level, which should be returned in lowercase:</p>\n<pre><code class=\"language-fsharp\">logLevel \"[ERROR]: Invalid operation\"\n// =&gt; \"error\"\n</code></pre>\n", # rubocop:disable Layout/LineLength
      "<p>Implement the <code>reformat</code> function that reformats the log line, putting the message first and the log level after it in\nparentheses:</p>\n<pre><code class=\"language-fsharp\">reformat \"[INFO]: Operation completed\"\n// =&gt; \"Operation completed (info)\"\n</code></pre>\n" # rubocop:disable Layout/LineLength
    ]
    assert_equal expected, (serialized[:tasks].map { |task| task[:text] })
  end

  test "serialize task hints" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, slug: 'log-levels'

    serialized = SerializeExerciseInstructions.(exercise)

    expected = [
      ["<p>There are <a href=\"https://docs.microsoft.com/en-us/dotnet/api/system.string.indexof?view=netcore-3.1\" target=\"_blank\">several methods</a> to find\nthe index at which some text occurs in a <code>string</code>.</p>\n", # rubocop:disable Layout/LineLength
       "<p>Removing white space is <a href=\"https://docs.microsoft.com/en-us/dotnet/api/system.string.trim?view=netcore-3.1\" target=\"_blank\">built-in</a>.</p>\n"], # rubocop:disable Layout/LineLength
      ["<p>A <code>string</code> can be converted to lowercase using a <a href=\"https://docs.microsoft.com/en-us/dotnet/api/system.string.tolower?view=netcore-3.1\" target=\"_blank\">built-in\nmethod</a>.</p>\n"], # rubocop:disable Layout/LineLength
      ["<p>There are several ways to <a href=\"https://exercism.github.io/v3/#/languages/fsharp/docs/string_concatenation\" target=\"_blank\">concatenate\nstrings</a>.</p>\n"] # rubocop:disable Layout/LineLength
    ]
    assert_equal expected, (serialized[:tasks].map { |task| task[:hints] })
  end

  test "serialize exercise without general hints" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, slug: 'cars-assemble'

    serialized = SerializeExerciseInstructions.(exercise)

    assert_empty serialized[:general_hints]
  end

  test "serialize exercise with some tasks missing hints" do
    track = create :track, slug: 'csharp'
    exercise = create :concept_exercise, track: track, slug: 'datetime'

    serialized = SerializeExerciseInstructions.(exercise)

    assert serialized[:tasks][0][:hints].present?
    assert_empty serialized[:tasks][1][:hints]
    assert serialized[:tasks][2][:hints].present?
    assert_empty serialized[:tasks][3][:hints]
    assert_empty serialized[:tasks][4][:hints]
  end
end
