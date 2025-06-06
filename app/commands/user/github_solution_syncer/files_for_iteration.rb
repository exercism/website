class User::GithubSolutionSyncer
  class FilesForIteration
    include Mandate

    initialize_with :syncer, :iteration

    def call
      files.map do |filename, content|
        next unless content.to_s.scrub("").present?

        {
          path: "#{path}/#{filename}",
          mode: "100644",
          type: "blob",
          content:
        }
      end.compact
    end

    private
    delegate :user, :track, :exercise, to: :iteration

    def files
      exercise_files.merge(submission_files)
    end

    def exercise_files
      return {} unless syncer.sync_exercise_files?

      iteration.solution.git_exercise.cli_files
    end

    def submission_files
      iteration.submission.files.each_with_object({}) do |file, hash|
        hash[file.filename] = file.content
      end
    end

    memoize
    def path
      syncer.path_template.
        gsub("$track_title", track.title).
        gsub("$track_slug", track.slug).
        gsub("$exercise_title", exercise.title).
        gsub("$exercise_slug", exercise.slug).
        gsub("$iteration_idx", iteration.idx.to_s).
        gsub("//", "/").
        gsub(%r{/$}, "")
    end
  end
end
