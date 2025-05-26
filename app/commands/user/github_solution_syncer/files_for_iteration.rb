class User::GithubSolutionSyncer
  class FilesForIteration
    include Mandate

    initialize_with :syncer, :iteration

    def call
      # Build a tree with all the new/updated files
      files.map do |filename, content|
        {
          path: "#{path}/#{filename}",
          mode: "100644",
          type: "blob",
          content:
        }
      end
    end

    private
    delegate :user, :track, :exercise, to: :iteration

    def files
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
