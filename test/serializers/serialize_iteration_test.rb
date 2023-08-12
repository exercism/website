require 'test_helper'

class SerializeIterationTest < ActiveSupport::TestCase
  test "basic to_hash" do
    freeze_time do
      track = create :track, slug: 'ruby'
      exercise = create :concept_exercise, track:, slug: 'bob'
      solution = create(:concept_solution, exercise:)
      submission = create(:submission, solution:)
      iteration = create(:iteration, solution:, submission:)
      file = create(:submission_file, submission:)
      iteration.stubs(
        representer_feedback: "foobar",
        analyzer_feedback: "barfoo",
        num_essential_automated_comments: 5,
        num_actionable_automated_comments: 2,
        num_non_actionable_automated_comments: 1,
        num_celebratory_automated_comments: 3
      )

      expected = {
        uuid: iteration.uuid,
        submission_uuid: submission.uuid,
        idx: 0,
        status: "untested",
        num_essential_automated_comments: 5,
        num_actionable_automated_comments: 2,
        num_non_actionable_automated_comments: 1,
        num_celebratory_automated_comments: 3,
        submission_method: "cli",
        created_at: Time.current.iso8601,
        tests_status: "not_queued",
        representer_feedback: "foobar",
        analyzer_feedback: "barfoo",
        is_published: false,
        is_latest: true,
        files: [{
          filename: file.filename,
          content: file.content,
          digest: file.digest
        }],
        links: {
          self: Exercism::Routes.track_exercise_iterations_url(track, exercise, idx: iteration.idx),
          automated_feedback: Exercism::Routes.automated_feedback_api_solution_iteration_url(iteration.solution.uuid, iteration.uuid),
          delete: Exercism::Routes.api_solution_iteration_url(iteration.solution.uuid, iteration.uuid),
          solution: Exercism::Routes.track_exercise_url(track, exercise),
          test_run: Exercism::Routes.api_solution_submission_test_run_url(iteration.solution.uuid,
            iteration.submission.uuid),
          files: Exercism::Routes.api_solution_submission_files_url(solution.uuid, submission.uuid)
        }
      }

      assert_equal expected, SerializeIteration.(iteration, sideload: %i[files automated_feedback])
    end
  end

  test "deleted version" do
    freeze_time do
      track = create :track, slug: 'ruby'
      exercise = create :concept_exercise, track:, slug: 'bob'
      solution = create(:concept_solution, exercise:)
      submission = create(:submission, solution:)
      iteration = create :iteration, solution:, submission:, deleted_at: Time.current
      create(:submission_file, submission:)

      expected = {
        uuid: iteration.uuid,
        idx: 0,
        status: "deleted",
        num_essential_automated_comments: 0,
        num_actionable_automated_comments: 0,
        num_non_actionable_automated_comments: 0,
        num_celebratory_automated_comments: 0,
        submission_method: "cli",
        created_at: Time.current.iso8601,
        tests_status: "not_queued",
        representer_feedback: "not_queued",
        analyzer_feedback: "not_queued",
        is_published: false,
        files: [],
        links: {
          self: Exercism::Routes.track_exercise_iterations_url(track, exercise, idx: iteration.idx),
          solution: Exercism::Routes.track_exercise_url(track, exercise)
        }
      }

      assert_equal expected, SerializeIteration.(iteration, sideload: [:files])
    end
  end
end
