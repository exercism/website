class Submission
  class TestRun
    class Init
      include Mandate

      initialize_with :submission

      def call
        ToolingJob::Create.(
          :test_runner,
          submission.uuid,
          solution.track.slug,
          solution.exercise.slug,
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
          # Skip non-functional files
          next false if filepath.starts_with?(".docs")
          next false if filepath == "README.md"

          # Skip submitted files
          next false if submission.valid_filepaths.include?(filepath)

          true
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
