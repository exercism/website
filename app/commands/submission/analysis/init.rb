class Submission
  class Analysis
    class Init
      include Mandate

      initialize_with :submission

      def call
        ToolingJob::Create.(
          :analyzer,
          submission_uuid: submission.uuid,
          language: solution.track.slug,
          exercise: solution.exercise.slug,
          source: {
            submission_efs_root: submission.uuid,
            submission_filepaths: submission_filepaths,
            exercise_git_repo: solution.track.slug,
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
        exercise_repo.tooling_filepaths.map do |filepath|
          next unless filepath.starts_with?(".meta")
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
