class Submission
  class TestRun
    class Init
      include Mandate

      def initialize(submission, head_run: false, git_sha: nil)
        @submission = submission
        @head_run = !!head_run
        @git_sha = git_sha || solution.git_sha
      end

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
            exercise_git_sha: git_sha,
            exercise_git_dir: exercise_repo.dir,
            exercise_filepaths: exercise_filepaths
          },
          head_run: head_run?
        ).tap do
          head_run? ?
            submission.solution.published_iteration_head_tests_status_queued! :
            submission.tests_queued!
        end
      end

      private
      attr_reader :submission, :git_sha

      def head_run?
        @head_run
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
    end
  end
end
