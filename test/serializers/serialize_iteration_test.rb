require 'test_helper'

class SerializeIterationTest < ActiveSupport::TestCase
  test "basic to_hash" do
    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track: track, slug: 'bob'
    solution = create :concept_solution, exercise: exercise
    submission = create :submission, solution: solution
    iteration = create :iteration, solution: solution, submission: submission

    expected = {
      uuid: iteration.uuid,
      submission_uuid: submission.uuid,
      idx: 0,
      submission_method: "cli",
      created_at: Time.current.iso8601,
      tests_status: "not_queued",
      representation_status: "not_queued",
      analysis_status: "not_queued",
      links: {
        self: "https://test.exercism.io/tracks/ruby/exercises/bob/iterations?idx=0"
      }
    }

    assert_equal expected, SerializeIteration.(iteration)
  end
end
