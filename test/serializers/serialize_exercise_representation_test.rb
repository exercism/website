require 'test_helper'

class SerializeExerciseRepresentationTest < ActiveSupport::TestCase
  test "serialize representation with feedback" do
    last_submitted_at = Time.zone.now - 2.days
    track = create :track, title: 'Ruby'
    exercise = create(:practice_exercise, title: 'Bob', track:)
    representation = create(:exercise_representation, id: 3, feedback_markdown: 'Yay', feedback_type: :essential,
      exercise:, num_submissions: 5, last_submitted_at:)
    create :submission_file, submission: representation.source_submission, filename: "impl.rb", content: "Impl // Foo",
      digest: "fd4aee90ec004b1dab8a7baccd67b12e"
    create :submission_representation, submission: representation.source_submission, ast_digest: representation.ast_digest

    expected = {
      id: 3,
      exercise: {
        icon_url: 'https://assets.exercism.org/exercises/bob.svg',
        title: 'Bob'
      },
      track: {
        icon_url: 'https://assets.exercism.org/tracks/ruby.svg',
        title: 'Ruby',
        highlightjs_language: 'ruby'
      },
      num_submissions: 5,
      appears_frequently: true,
      feedback_markdown: "Yay",
      feedback_type: :essential,
      draft_feedback_markdown: nil,
      draft_feedback_type: nil,
      last_submitted_at:,
      files:
      [{ filename: "log_line_parser.rb",
         type: :exercise,
         digest: nil,
         content: "module LogLineParser\n  def self.message(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.message method'\n  end\n\n  def self.log_level(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.log_level method'\n  end\n\n  def self.reformat(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.reformat method'\n  end\nend\n" }, # rubocop:disable Layout/LineLength
       { filename: "impl.rb",
         type: :legacy,
         digest: "fd4aee90ec004b1dab8a7baccd67b12e",
         content: "Impl // Foo" }],
      instructions: "<p>In this exercise you'll be processing log-lines.</p>\n<p>Each log line is a string formatted as follows: <code>\"[&lt;LEVEL&gt;]: &lt;MESSAGE&gt;\"</code>.</p>\n<p>There are three different log levels:</p>\n<ul>\n<li><code>INFO</code></li>\n<li><code>WARNING</code></li>\n<li><code>ERROR</code></li>\n</ul>\n<p>You have three tasks, each of which will take a log line and ask you to do something with it.</p>\n<h3 id=\"h-1-get-message-from-a-log-line\">1. Get message from a log line</h3>\n<p>Implement the <code>LogLineParser.message</code> method to return a log line's message:</p>\n<pre><code class=\"language-ruby\">LogLineParser.message('[ERROR]: Invalid operation')\n// Returns: \"Invalid operation\"\n</code></pre>\n<p>Any leading or trailing white space should be removed:</p>\n<pre><code class=\"language-ruby\">LogLineParser.message('[WARNING]:  Disk almost full\\r\\n')\n// Returns: \"Disk almost full\"\n</code></pre>\n<h3 id=\"h-2-get-log-level-from-a-log-line\">2. Get log level from a log line</h3>\n<p>Implement the <code>LogLineParser.log_level</code> method to return a log line's log level, which should be returned in lowercase:</p>\n<pre><code class=\"language-ruby\">LogLineParser.log_level('[ERROR]: Invalid operation')\n// Returns: \"error\"\n</code></pre>\n<h3 id=\"h-3-reformat-a-log-line\">3. Reformat a log line</h3>\n<p>Implement the <code>LogLineParser.reformat</code> method that reformats the log line, putting the message first and the log level after it in parentheses:</p>\n<pre><code class=\"language-ruby\">LogLineParser.reformat('[INFO]: Operation completed')\n// Returns: \"Operation completed (info)\"\n</code></pre>\n", # rubocop:disable Layout/LineLength
      test_files: [
        {
          filename: "log_line_parser_test.rb",
          content: "# frozen_string_literal: true\n\nrequire 'minitest/autorun'\nrequire_relative 'log_line_parser'\n\nclass LogLineParserTest < Minitest::Test\n  def test_error_message\n    assert_equal 'Stack overflow', LogLineParser.message('[ERROR]: Stack overflow')\n  end\n\n  def test_warning_message\n    assert_equal 'Disk almost full', LogLineParser.message('[WARNING]: Disk almost full')\n  end\n\n  def test_info_message\n    assert_equal 'File moved', LogLineParser.message('[INFO]: File moved')\n  end\n\n  def test_message_with_leading_and_trailing_space\n    assert_equal 'Timezone not set', LogLineParser.message(\"[WARNING]:   \\tTimezone not set  \\r\\n\")\n  end\n\n  def test_error_log_level\n    assert_equal 'error', LogLineParser.log_level('[ERROR]: Disk full')\n  end\n\n  def test_warning_log_level\n    assert_equal 'warning', LogLineParser.log_level('[WARNING]: Unsafe password')\n  end\n\n  def test_info_log_level\n    assert_equal 'info', LogLineParser.log_level('[INFO]: Timezone changed')\n  end\n\n  def test_erro_reformat\n    assert_equal 'Segmentation fault (error)', LogLineParser.reformat('[ERROR]: Segmentation fault')\n  end\n\n  def test_warning_reformat\n    assert_equal 'Decreased performance (warning)', LogLineParser.reformat('[WARNING]: Decreased performance')\n  end\n\n  def test_info_reformat\n    assert_equal 'Disk defragmented (info)', LogLineParser.reformat('[INFO]: Disk defragmented')\n  end\n\n  def rest_reformat_with_leading_and_trailing_space\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\n\n  def test_new_test_for_diffs\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\nend\n" # rubocop:disable Layout/LineLength
        }
      ],
      links: {
        self: "/mentoring/automation/#{representation.uuid}/edit",
        update: "/api/v2/mentoring/representations/#{representation.uuid}"
      }
    }

    assert_equal expected, SerializeExerciseRepresentation.(representation)
  end

  test "serialize representation with draft feedback" do
    last_submitted_at = Time.zone.now - 2.days
    track = create :track, title: 'Ruby'
    exercise = create(:practice_exercise, title: 'Bob', track:)
    representation = create(:exercise_representation, id: 3, draft_feedback_markdown: 'Yay', draft_feedback_type: :essential,
      exercise:, num_submissions: 5, last_submitted_at:)
    create :submission_file, submission: representation.source_submission, filename: "impl.rb", content: "Impl // Foo",
      digest: "fd4aee90ec004b1dab8a7baccd67b12e"
    create :submission_representation, submission: representation.source_submission, ast_digest: representation.ast_digest

    expected = {
      id: 3,
      exercise: {
        icon_url: 'https://assets.exercism.org/exercises/bob.svg',
        title: 'Bob'
      },
      track: {
        icon_url: 'https://assets.exercism.org/tracks/ruby.svg',
        title: 'Ruby',
        highlightjs_language: 'ruby'
      },
      num_submissions: 5,
      appears_frequently: true,
      feedback_markdown: nil,
      feedback_type: nil,
      draft_feedback_markdown: "Yay",
      draft_feedback_type: :essential,
      last_submitted_at:,
      files:
      [{ filename: "log_line_parser.rb",
         type: :exercise,
         digest: nil,
         content: "module LogLineParser\n  def self.message(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.message method'\n  end\n\n  def self.log_level(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.log_level method'\n  end\n\n  def self.reformat(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.reformat method'\n  end\nend\n" }, # rubocop:disable Layout/LineLength
       { filename: "impl.rb",
         type: :legacy,
         digest: "fd4aee90ec004b1dab8a7baccd67b12e",
         content: "Impl // Foo" }],
      instructions: "<p>In this exercise you'll be processing log-lines.</p>\n<p>Each log line is a string formatted as follows: <code>\"[&lt;LEVEL&gt;]: &lt;MESSAGE&gt;\"</code>.</p>\n<p>There are three different log levels:</p>\n<ul>\n<li><code>INFO</code></li>\n<li><code>WARNING</code></li>\n<li><code>ERROR</code></li>\n</ul>\n<p>You have three tasks, each of which will take a log line and ask you to do something with it.</p>\n<h3 id=\"h-1-get-message-from-a-log-line\">1. Get message from a log line</h3>\n<p>Implement the <code>LogLineParser.message</code> method to return a log line's message:</p>\n<pre><code class=\"language-ruby\">LogLineParser.message('[ERROR]: Invalid operation')\n// Returns: \"Invalid operation\"\n</code></pre>\n<p>Any leading or trailing white space should be removed:</p>\n<pre><code class=\"language-ruby\">LogLineParser.message('[WARNING]:  Disk almost full\\r\\n')\n// Returns: \"Disk almost full\"\n</code></pre>\n<h3 id=\"h-2-get-log-level-from-a-log-line\">2. Get log level from a log line</h3>\n<p>Implement the <code>LogLineParser.log_level</code> method to return a log line's log level, which should be returned in lowercase:</p>\n<pre><code class=\"language-ruby\">LogLineParser.log_level('[ERROR]: Invalid operation')\n// Returns: \"error\"\n</code></pre>\n<h3 id=\"h-3-reformat-a-log-line\">3. Reformat a log line</h3>\n<p>Implement the <code>LogLineParser.reformat</code> method that reformats the log line, putting the message first and the log level after it in parentheses:</p>\n<pre><code class=\"language-ruby\">LogLineParser.reformat('[INFO]: Operation completed')\n// Returns: \"Operation completed (info)\"\n</code></pre>\n", # rubocop:disable Layout/LineLength
      test_files: [
        {
          filename: "log_line_parser_test.rb",
          content: "# frozen_string_literal: true\n\nrequire 'minitest/autorun'\nrequire_relative 'log_line_parser'\n\nclass LogLineParserTest < Minitest::Test\n  def test_error_message\n    assert_equal 'Stack overflow', LogLineParser.message('[ERROR]: Stack overflow')\n  end\n\n  def test_warning_message\n    assert_equal 'Disk almost full', LogLineParser.message('[WARNING]: Disk almost full')\n  end\n\n  def test_info_message\n    assert_equal 'File moved', LogLineParser.message('[INFO]: File moved')\n  end\n\n  def test_message_with_leading_and_trailing_space\n    assert_equal 'Timezone not set', LogLineParser.message(\"[WARNING]:   \\tTimezone not set  \\r\\n\")\n  end\n\n  def test_error_log_level\n    assert_equal 'error', LogLineParser.log_level('[ERROR]: Disk full')\n  end\n\n  def test_warning_log_level\n    assert_equal 'warning', LogLineParser.log_level('[WARNING]: Unsafe password')\n  end\n\n  def test_info_log_level\n    assert_equal 'info', LogLineParser.log_level('[INFO]: Timezone changed')\n  end\n\n  def test_erro_reformat\n    assert_equal 'Segmentation fault (error)', LogLineParser.reformat('[ERROR]: Segmentation fault')\n  end\n\n  def test_warning_reformat\n    assert_equal 'Decreased performance (warning)', LogLineParser.reformat('[WARNING]: Decreased performance')\n  end\n\n  def test_info_reformat\n    assert_equal 'Disk defragmented (info)', LogLineParser.reformat('[INFO]: Disk defragmented')\n  end\n\n  def rest_reformat_with_leading_and_trailing_space\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\n\n  def test_new_test_for_diffs\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\nend\n" # rubocop:disable Layout/LineLength
        }
      ],
      links: {
        self: "/mentoring/automation/#{representation.uuid}/edit",
        update: "/api/v2/mentoring/representations/#{representation.uuid}"
      }
    }

    assert_equal expected, SerializeExerciseRepresentation.(representation)
  end

  test "serialize representation without feedback" do
    last_submitted_at = Time.zone.now - 2.days
    track = create :track, title: 'Ruby'
    exercise = create(:practice_exercise, title: 'Bob', track:)
    representation = create(:exercise_representation, id: 3, exercise:, num_submissions: 5,
      last_submitted_at:)
    create :submission_file, submission: representation.source_submission, filename: "impl.rb", content: "Impl // Foo",
      digest: "fd4aee90ec004b1dab8a7baccd67b12e"
    create :submission_representation, submission: representation.source_submission, ast_digest: representation.ast_digest

    expected = {
      id: 3,
      exercise: {
        icon_url: 'https://assets.exercism.org/exercises/bob.svg',
        title: 'Bob'
      },
      track: {
        icon_url: 'https://assets.exercism.org/tracks/ruby.svg',
        title: 'Ruby',
        highlightjs_language: 'ruby'
      },
      num_submissions: 5,
      appears_frequently: true,
      feedback_markdown: nil,
      feedback_type: nil,
      draft_feedback_markdown: nil,
      draft_feedback_type: nil,
      last_submitted_at:,
      files:
      [{ filename: "log_line_parser.rb",
         type: :exercise,
         digest: nil,
         content: "module LogLineParser\n  def self.message(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.message method'\n  end\n\n  def self.log_level(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.log_level method'\n  end\n\n  def self.reformat(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.reformat method'\n  end\nend\n" }, # rubocop:disable Layout/LineLength
       { filename: "impl.rb",
         type: :legacy,
         digest: "fd4aee90ec004b1dab8a7baccd67b12e",
         content: "Impl // Foo" }],
      instructions: "<p>In this exercise you'll be processing log-lines.</p>\n<p>Each log line is a string formatted as follows: <code>\"[&lt;LEVEL&gt;]: &lt;MESSAGE&gt;\"</code>.</p>\n<p>There are three different log levels:</p>\n<ul>\n<li><code>INFO</code></li>\n<li><code>WARNING</code></li>\n<li><code>ERROR</code></li>\n</ul>\n<p>You have three tasks, each of which will take a log line and ask you to do something with it.</p>\n<h3 id=\"h-1-get-message-from-a-log-line\">1. Get message from a log line</h3>\n<p>Implement the <code>LogLineParser.message</code> method to return a log line's message:</p>\n<pre><code class=\"language-ruby\">LogLineParser.message('[ERROR]: Invalid operation')\n// Returns: \"Invalid operation\"\n</code></pre>\n<p>Any leading or trailing white space should be removed:</p>\n<pre><code class=\"language-ruby\">LogLineParser.message('[WARNING]:  Disk almost full\\r\\n')\n// Returns: \"Disk almost full\"\n</code></pre>\n<h3 id=\"h-2-get-log-level-from-a-log-line\">2. Get log level from a log line</h3>\n<p>Implement the <code>LogLineParser.log_level</code> method to return a log line's log level, which should be returned in lowercase:</p>\n<pre><code class=\"language-ruby\">LogLineParser.log_level('[ERROR]: Invalid operation')\n// Returns: \"error\"\n</code></pre>\n<h3 id=\"h-3-reformat-a-log-line\">3. Reformat a log line</h3>\n<p>Implement the <code>LogLineParser.reformat</code> method that reformats the log line, putting the message first and the log level after it in parentheses:</p>\n<pre><code class=\"language-ruby\">LogLineParser.reformat('[INFO]: Operation completed')\n// Returns: \"Operation completed (info)\"\n</code></pre>\n", # rubocop:disable Layout/LineLength
      test_files: [
        {
          filename: "log_line_parser_test.rb",
          content: "# frozen_string_literal: true\n\nrequire 'minitest/autorun'\nrequire_relative 'log_line_parser'\n\nclass LogLineParserTest < Minitest::Test\n  def test_error_message\n    assert_equal 'Stack overflow', LogLineParser.message('[ERROR]: Stack overflow')\n  end\n\n  def test_warning_message\n    assert_equal 'Disk almost full', LogLineParser.message('[WARNING]: Disk almost full')\n  end\n\n  def test_info_message\n    assert_equal 'File moved', LogLineParser.message('[INFO]: File moved')\n  end\n\n  def test_message_with_leading_and_trailing_space\n    assert_equal 'Timezone not set', LogLineParser.message(\"[WARNING]:   \\tTimezone not set  \\r\\n\")\n  end\n\n  def test_error_log_level\n    assert_equal 'error', LogLineParser.log_level('[ERROR]: Disk full')\n  end\n\n  def test_warning_log_level\n    assert_equal 'warning', LogLineParser.log_level('[WARNING]: Unsafe password')\n  end\n\n  def test_info_log_level\n    assert_equal 'info', LogLineParser.log_level('[INFO]: Timezone changed')\n  end\n\n  def test_erro_reformat\n    assert_equal 'Segmentation fault (error)', LogLineParser.reformat('[ERROR]: Segmentation fault')\n  end\n\n  def test_warning_reformat\n    assert_equal 'Decreased performance (warning)', LogLineParser.reformat('[WARNING]: Decreased performance')\n  end\n\n  def test_info_reformat\n    assert_equal 'Disk defragmented (info)', LogLineParser.reformat('[INFO]: Disk defragmented')\n  end\n\n  def rest_reformat_with_leading_and_trailing_space\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\n\n  def test_new_test_for_diffs\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\nend\n" # rubocop:disable Layout/LineLength
        }
      ],
      links: {
        self: "/mentoring/automation/#{representation.uuid}/edit",
        update: "/api/v2/mentoring/representations/#{representation.uuid}"
      }
    }
    assert_equal expected, SerializeExerciseRepresentation.(representation)
  end
end
