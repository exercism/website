require 'test_helper'

class SerializeExerciseRepresentationTest < ActiveSupport::TestCase
  test "serialize representation" do
    last_submitted_at = Time.zone.now - 2.days
    track = create :track, title: 'Ruby'
    exercise = create :practice_exercise, title: 'Bob', track: track
    representation = create :exercise_representation, id: 3, feedback_markdown: 'Yay', exercise: exercise, num_submissions: 5,
      last_submitted_at: last_submitted_at
    create :submission_file, submission: representation.source_submission, filename: "impl.rb", content: "Impl // Foo",
      digest: "fd4aee90ec004b1dab8a7baccd67b12e"
    create :submission_representation, submission: representation.source_submission, ast_digest: representation.ast_digest

    expected = {
      id: 3,
      exercise: {
        icon_url: 'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/bob.svg',
        title: 'Bob'
      },
      track: {
        icon_url: 'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
        title: 'Ruby'
      },
      num_submissions: 5,
      appears_frequently: true,
      feedback_markdown: "Yay",
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
      links: {
        self: '/mentoring/automation/3/edit',
        update: '/api/v2/mentoring/representations/3'
      }
    }

    assert_equal expected, SerializeExerciseRepresentation.(representation)
  end
end
