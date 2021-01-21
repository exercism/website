class Submission
  class TestRun
    class Init
      include Mandate

      initialize_with :submission

      def call
        ToolingJob::Create.(
          :test_runner,
          submission_uuid: submission.uuid,
          language: solution.track.slug,
          exercise: solution.exercise.slug,
          source: {
            submission_efs_root: submission.uuid,
            submission_filepaths: submission_filepaths,
            exercise_git_repo: "v3", # Change to solution.track.slug when we're out of the monorepo
            exercise_git_sha: exercise_repo.normalised_git_sha,
            exercise_git_dir: exercise_repo.dir,
            exercise_filepaths: exercise_filepaths
          }
        )
      end

      memoize
      delegate :solution, to: :submission

      memoize
      def submission_filepaths
        submission.files.map do |file|
          filename = file.filename

          # TODO: Add a test for this.
          next if filename.match?(%r{[^a-zA-Z0-9_./-]})

          next if filename.match?(test_regexp)
          next if filename.starts_with?(".meta")

          filename
        end.compact
      end

      def exercise_filepaths
        exercise_repo.non_ignored_filepaths.map do |filepath|
          # Skip non-functional files
          next if filepath.starts_with?(".docs")
          next if filepath == "README.md"

          next if submission_filepaths.include?(filepath)

          filepath
        end.compact
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
