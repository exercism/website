require 'test_helper'

class SerializeExerciseAssignmentTest < ActiveSupport::TestCase
  test "serialize general hints for concept exercise" do
    solution = create :concept_solution

    serialized = SerializeExerciseAssignment.(solution)

    expected = [
      <<~HINT
        <ul>
        <li>The <a href=\"http://ruby-for-beginners.rubymonstas.org/built_in_classes/strings.html\" target=\"_blank\" rel=\"noreferrer\">rubymostas strings guide</a> has a nice\nintroduction to Ruby strings.</li>\n<li>The <code>String</code> object has many useful <a href=\"https://ruby-doc.org/core-2.7.0/String.html\" target=\"_blank\" rel=\"noreferrer\">built-in methods</a>.</li>
        </ul>
      HINT
    ]
    assert_equal expected, serialized[:general_hints]
  end

  test "serialize general hints for practice exercise" do
    solution = create :practice_solution

    serialized = SerializeExerciseAssignment.(solution)

    expected = [
      <<~HINT
        <ul>
        <li>There are many useful string methods built-in</li>
        </ul>
      HINT
    ]
    assert_equal expected, serialized[:general_hints]
  end

  test "serialize general hints for practice exercise without hints" do
    exercise = create :practice_exercise, slug: 'allergies'
    solution = create(:practice_solution, exercise:)

    serialized = SerializeExerciseAssignment.(solution)

    assert_empty serialized[:general_hints]
  end

  test "serialize overview for concept exercise" do
    solution = create :concept_solution

    serialized = SerializeExerciseAssignment.(solution)

    expected = <<~OVERVIEW
      <p>In this exercise you'll be processing log-lines.</p>
      <p>Each log line is a string formatted as follows: <code>\"[&lt;LEVEL&gt;]: &lt;MESSAGE&gt;\"</code>.</p>
      <p>There are three different log levels:</p>
      <ul>
      <li><code>INFO</code></li>
      <li><code>WARNING</code></li>
      <li><code>ERROR</code></li>
      </ul>
      <p>You have three tasks, each of which will take a log line and ask you to do something with it.</p>
    OVERVIEW

    assert_equal expected, serialized[:overview]
  end

  test "serialize overview for practice exercise without appends" do
    exercise = create :practice_exercise, slug: 'allergies'
    solution = create(:practice_solution, exercise:)

    serialized = SerializeExerciseAssignment.(solution)

    expected = "<p>Instructions for allergies</p>\n"
    assert_equal expected, serialized[:overview]
  end

  test "serialize overview for practice exercise with appends" do
    solution = create :practice_solution

    serialized = SerializeExerciseAssignment.(solution)

    expected = <<~OVERVIEW
      <p>Instructions for bob</p>
      <p>Extra instructions for bob</p>
    OVERVIEW
    assert_equal expected, serialized[:overview]
  end

  test "serialize concept exercise task ids" do
    solution = create :concept_solution

    serialized = SerializeExerciseAssignment.(solution)

    expected = [1, 2, 3]
    assert_equal expected, (serialized[:tasks].map { |task| task[:id] })
  end

  test "serialize concept exercise task titles" do
    solution = create :concept_solution

    serialized = SerializeExerciseAssignment.(solution)

    expected = ['Get message from a log line', 'Get log level from a log line', 'Reformat a log line']
    assert_equal expected, (serialized[:tasks].map { |task| task[:title] })
  end

  test "serialize concept exercise task text" do
    solution = create :concept_solution

    serialized = SerializeExerciseAssignment.(solution)

    expected = [<<~HINT_1, <<~HINT_2, <<~HINT_3]
      <p>Implement the <code>LogLineParser.message</code> method to return a log line's message:</p>
      <pre><code class=\"language-ruby\">LogLineParser.message('[ERROR]: Invalid operation')
      // Returns: \"Invalid operation\"\n</code></pre>
      <p>Any leading or trailing white space should be removed:</p>
      <pre><code class=\"language-ruby\">LogLineParser.message('[WARNING]:  Disk almost full\\r\\n')
      // Returns: \"Disk almost full\"\n</code></pre>
    HINT_1
      <p>Implement the <code>LogLineParser.log_level</code> method to return a log line's log level, which should be returned in lowercase:</p>
      <pre><code class=\"language-ruby\">LogLineParser.log_level('[ERROR]: Invalid operation')
      // Returns: \"error\"\n</code></pre>
    HINT_2
      <p>Implement the <code>LogLineParser.reformat</code> method that reformats the log line, putting the message first and the log level
      after it in parentheses:</p>
      <pre><code class=\"language-ruby\">LogLineParser.reformat('[INFO]: Operation completed')
      // Returns: \"Operation completed (info)\"
      </code></pre>
    HINT_3

    assert_equal expected, (serialized[:tasks].map { |task| task[:text] })
  end

  test "serialize concept exercise task hints" do
    solution = create :concept_solution

    serialized = SerializeExerciseAssignment.(solution)

    expected = [[<<~HINT_1], [<<~HINT_2], [<<~HINT_3]]
      <ul>
      <li>There are different ways to search for text in a string, which can be found on the <a href=\"https://ruby-doc.org/core-2.7.0/String.html\" target=\"_blank\" rel=\"noreferrer\">Ruby language official
      documentation</a>.</li>
      <li>There are <a href=\"https://ruby-doc.org/core-2.7.0/String.html#method-i-strip\" target=\"_blank\" rel=\"noreferrer\">built in methods</a> to strip white space.</li>
      </ul>
    HINT_1
      <ul>
      <li>Ruby <code>String</code> objects have a <a href=\"https://ruby-doc.org/core-2.7.0/String.html#method-i-downcase\" target=\"_blank\" rel=\"noreferrer\">method</a> to perform this
      operation.</li>
      </ul>
    HINT_2
      <ul>
      <li>There are several ways to <a href=\"http://ruby-for-beginners.rubymonstas.org/built_in_classes/strings.html\" target=\"_blank\" rel=\"noreferrer\">concatenate
      strings</a>, but the preferred one is usually
      <a href=\"http://ruby-for-beginners.rubymonstas.org/built_in_classes/strings.html\" target=\"_blank\" rel=\"noreferrer\">string interpolation</a>
      </li>
      </ul>
    HINT_3
    assert_equal expected, (serialized[:tasks].map { |task| task[:hints] })
  end

  test "serialize hints with reference links" do
    hints = <<~HINTS.strip
      # Hints

      ## General

      - Hint [number one][hint-one]
      - Hint [number two][hint-two]

      ## 1. Task

      - Some task hints

      [hint-one]: http://exercism.org/about
      [hint-two]: http://exercism.org/tracks
    HINTS

    solution = create :concept_solution
    solution.stubs(:hints).returns(hints)

    serialized = SerializeExerciseAssignment.(solution)

    expected = [
      <<~HINT
        <ul>
        <li>Hint <a href=\"http://exercism.org/about\">number one</a>
        </li>
        <li>Hint <a href=\"http://exercism.org/tracks\">number two</a>
        </li>
        </ul>
      HINT
    ]
    assert_equal expected, serialized[:general_hints]
  end

  test "serialize hints with complex content" do
    hints = <<~HINTS.strip
      # Hints

      ## General

      - Hint one
        - Sub hint one
        - Sub hint two
      - Hint two
      - Hint three
        - Sub hint three

      These are more hints

      ~~~exercism/note
      This is a note
      ~~~

      ## 1. Task one

      - Task hint one
        - Task sub hint one

      ## 2. Task two

      - Task hint two
    HINTS

    solution = create :concept_solution
    solution.stubs(:hints).returns(hints)

    serialized = SerializeExerciseAssignment.(solution)

    expected = [<<~HINT_1, <<~HINT_2, <<~HINT_3]
      <ul>
      <li>Hint one
      <ul>
      <li>Sub hint one</li>
      <li>Sub hint two</li>
      </ul>
      </li>
      <li>Hint two</li>
      <li>Hint three
      <ul>
      <li>Sub hint three</li>
      </ul>
      </li>
      </ul>
    HINT_1
      <p>These are more hints</p>
    HINT_2
      <div class=\"c-textblock-note\">
      <div class=\"c-textblock-header\">Note</div>
      <div class=\"c-textblock-content\">
      <p>This is a note</p>
      </div>
      </div>
    HINT_3
    assert_equal expected, serialized[:general_hints]
  end

  test "serialize concept exercise without general hints" do
    exercise = create :concept_exercise, slug: 'numbers'
    solution = create(:concept_solution, exercise:)

    serialized = SerializeExerciseAssignment.(solution)

    assert_empty serialized[:general_hints]
  end

  test "serialize concept exercise with some tasks missing hints" do
    exercise = create :concept_exercise, slug: 'booleans'
    solution = create(:concept_solution, exercise:)

    serialized = SerializeExerciseAssignment.(solution)

    assert_equal 3, serialized[:tasks].length
    assert serialized[:tasks][0][:hints].present?
    assert_empty serialized[:tasks][1][:hints]
    assert serialized[:tasks][2][:hints].present?
  end

  test "practice exercise does not have any tasks" do
    solution = create :practice_solution

    serialized = SerializeExerciseAssignment.(solution)

    assert_empty serialized[:tasks]
  end

  test "uses solution git sha instead of exercise sha" do
    exercise = create :concept_exercise, slug: 'arrays', git_sha: '0913c69f21b3f81477337b259a21fb7278393bc1'
    solution = create :concept_solution, exercise:, git_sha: 'ef19c86ee73dfbd3df8f3d49251008783a51de91'

    serialized = SerializeExerciseAssignment.(solution)

    refute_includes serialized[:overview], 'that keeps track of how'
    assert_includes serialized[:overview], 'that tracks how'
  end

  test "serialize task with multiple lines of text" do
    solution = create :concept_solution

    instructions = <<~INSTRUCTIONS.strip
      # Instructions

      ## 1. Document filling out fields with blank values

      Add documentation and a typespec to the `Form.blanks/1` function. The documentation should read:

      ```
      Generates a string of a given length.

      This string can be used to fill out a form field that is supposed to have no value.
      Such fields cannot be left empty because a malicious third party could fill them out with false data.
      ```

      The typespec should explain that the function accepts a single argument, a non-negative integer, and returns a string.
    INSTRUCTIONS

    solution.git_exercise.stubs(:instructions).returns(instructions)

    serialized = SerializeExerciseAssignment.(solution)

    task = serialized[:tasks].first

    assert_equal "Document filling out fields with blank values", task[:title]
    expected_text = <<~TEXT
      <p>Add documentation and a typespec to the <code>Form.blanks/1</code> function. The documentation should read:</p>
      <pre><code class=\"language-plain\">Generates a string of a given length.

      This string can be used to fill out a form field that is supposed to have no value.
      Such fields cannot be left empty because a malicious third party could fill them out with false data.
      </code></pre>
      <p>The typespec should explain that the function accepts a single argument, a non-negative integer, and returns a string.</p>
    TEXT
    assert_equal expected_text, task[:text]
  end
end
