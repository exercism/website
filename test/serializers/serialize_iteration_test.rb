require 'test_helper'

class SerializeIterationTest < ActiveSupport::TestCase
  test "basic to_hash" do
    freeze_time do
      track = create :track, slug: 'ruby'
      exercise = create :concept_exercise, track: track, slug: 'bob'
      solution = create :concept_solution, exercise: exercise
      submission = create :submission, solution: solution
      iteration = create :iteration, solution: solution, submission: submission
      iteration.stubs(
        representer_feedback: "foobar",
        analyzer_feedback: "barfoo",
        num_essential_automated_comments: 5,
        num_actionable_automated_comments: 2,
        num_non_actionable_automated_comments: 1
      )

      expected = {
        uuid: iteration.uuid,
        submission_uuid: submission.uuid,
        idx: 0,
        status: "testing",
        num_essential_automated_comments: 5,
        num_actionable_automated_comments: 2,
        num_non_actionable_automated_comments: 1,
        submission_method: "cli",
        created_at: Time.current.iso8601,
        tests_status: "not_queued",
        representer_feedback: "foobar",
        analyzer_feedback: "barfoo",
        links: {
          self: "https://test.exercism.io/tracks/ruby/exercises/bob/iterations?idx=0",
          files: Exercism::Routes.api_solution_submission_files_url(solution.uuid, submission.uuid)
        }
      }

      assert_equal expected, SerializeIteration.(iteration)
    end
  end
end
