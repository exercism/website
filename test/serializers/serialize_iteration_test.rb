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
        is_published: false,
        links: {
          self: Exercism::Routes.track_exercise_iterations_url(track, exercise, idx: iteration.idx),
          solution: Exercism::Routes.track_exercise_url(track, exercise),
          files: Exercism::Routes.api_solution_submission_files_url(solution.uuid, submission.uuid)
        }
      }

      assert_equal expected, SerializeIteration.(iteration)
    end
  end
end
