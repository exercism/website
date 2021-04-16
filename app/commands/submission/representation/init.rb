class Submission
  class Representation
    class Init
      include Mandate

      initialize_with :submission

      def call
        ToolingJob::Create.(
          :representer,
          submission_uuid: submission.uuid,
          language: solution.track.slug,
          exercise: solution.exercise.slug,
          source: {
            submission_efs_root: submission.uuid,
            submission_filepaths: submission.valid_filepaths,
            exercise_git_repo: solution.track.slug,
            exercise_git_sha: exercise_repo.synced_git_sha,
            exercise_git_dir: exercise_repo.dir,
            exercise_filepaths: exercise_filepaths
          }
        )
      end

      memoize
      delegate :solution, to: :submission

      def exercise_filepaths
        exercise_repo.tooling_filepaths.select do |filepath|
          filepath.starts_with?(".meta")
        end
      end

      memoize
      def exercise_repo
        Git::Exercise.for_solution(solution)
      end

      memoize
      def test_regexp
        solution.track.test_regexp
      end
    end
  end
end
