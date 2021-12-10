class Submission
  class Analysis
    class Init
      include Mandate

      initialize_with :submission

      def call
        ToolingJob::Create.(
          :analyzer,
          submission.uuid,
          solution.track.slug,
          solution.exercise.slug,
          source: {
            submission_efs_root: submission.uuid,
            submission_filepaths: submission.valid_filepaths,
            exercise_git_repo: solution.track.slug,
            exercise_git_sha: solution.git_sha,
            exercise_git_dir: exercise_repo.dir,
            exercise_filepaths: exercise_filepaths
          }
        )
        submission.analysis_queued!
      end

      memoize
      delegate :solution, to: :submission

      def exercise_filepaths
        exercise_repo.tooling_filepaths.reject do |filepath|
          submission.valid_filepaths.include?(filepath)
        end
      end

      memoize
      def exercise_repo
        Git::Exercise.for_solution(solution)
      end
    end
  end
end
