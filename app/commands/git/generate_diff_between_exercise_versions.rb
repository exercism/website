module Git
  class GenerateDiffBetweenExerciseVersions
    include Mandate

    initialize_with :exercise, :old_slug, :old_sha

    def call
      changed_files.filter_map do |cf|
        next unless interesting_paths.include?(cf.filepath)

        {
          filename: cf.filename,
          diff: cf.diff
        }
      end
    end

    private
    memoize
    def changed_files
      changes = changed_in_git + changed_in_config
      changes.uniq(&:filepath)
    end

    def changed_in_git
      # This is a diff of two commits considering all files in the respective old and new directories
      raw_diff = `cd #{repo.send(:repo_dir)} && git diff #{old_sha} #{exercise.git_sha} -- #{old_git.dir} #{new_git.dir}` # rubocop:disable Layout/LineLength

      ProcessDiff.(raw_diff)
    end

    def changed_in_config
      return [] unless new_interesting_paths.present?

      first_sha = `cd #{repo.send(:repo_dir)} && git rev-list HEAD | tail -n 1`.strip # rubocop:disable Layout/LineLength

      new_interesting_paths.flat_map do |filepath|
        raw_diff = `cd #{repo.send(:repo_dir)} && git diff #{first_sha} #{exercise.git_sha} -- #{filepath}` # rubocop:disable Layout/LineLength
        ProcessDiff.(raw_diff)
      end
    end

    memoize
    def interesting_paths
      Set.new(
        [
          *old_git.important_absolute_filepaths,
          *new_git.important_absolute_filepaths
        ]
      )
    end

    memoize
    def new_interesting_paths
      new_git.important_absolute_filepaths - old_git.important_absolute_filepaths
    end

    memoize
    def old_git
      Git::Exercise.new(old_slug, exercise.git_type, old_sha, repo:)
    end

    memoize
    def new_git
      Git::Exercise.new(exercise.slug, exercise.git_type, exercise.git_sha, repo:)
    end

    memoize
    def repo
      Git::Repository.new(repo_url: exercise.track.repo_url)
    end

    class ProcessDiff
      include Mandate

      initialize_with :raw_diff

      # This loops through the diff and breaks it into
      # one Diff object per file.
      def call
        @diffs = []

        filepath = nil
        diff = nil

        raw_diff.lines.each do |line|
          # If we have a new diff, store the old one and reset
          if line.starts_with?("diff --git")
            add_diff!(filepath, diff)

            filepath = line.split(" b/").last.strip
            diff = []
          end

          diff << line
        end

        # Store the last one at the end of the file
        add_diff!(filepath, diff)

        @diffs
      end

      def add_diff!(filepath, lines)
        @diffs << Diff.new(filepath, lines.join) if filepath
      end

      Diff = Struct.new(:filepath, :diff) do
        def filename
          filepath.split('/').last
        end
      end
      private_constant :Diff
    end
  end
end
