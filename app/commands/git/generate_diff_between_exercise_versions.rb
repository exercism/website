module Git
  class GenerateDiffBetweenExerciseVersions
    include Mandate

    initialize_with :exercise, :old_slug, :old_sha

    def call
      changed_files.filter! do |diff|
        interesting_paths.include?(diff.filepath)
      end

      changed_files
    end

    private
    memoize
    def interesting_paths
      Set.new([
                *old_git.test_filepaths,
                *new_git.test_filepaths,
                new_git.instructions_filepath,
                new_git.instructions_append_filepath,
                new_git.introduction_filepath,
                new_git.introduction_append_filepath,
                new_git.hints_filepath
              ])
    end

    memoize
    def changed_files
      raw_diff = `cd #{repo.send(:repo_dir)} && git diff --merge-base #{old_sha} #{exercise.git_sha} -- #{new_git.dir}`

      diffs = []
      current = nil

      raw_diff.lines.each do |line|
        if line.starts_with?("diff --git")
          diffs << current if current

          current = Diff.new(
            line.split(" b/#{new_git.dir}/").last.strip,
            line.split(" b/").last.strip,
            ""
          )
        end
        current.diff += "#{line}\n"
      end
      diffs << current
      diffs
    end

    memoize
    def old_git
      Git::Exercise.new(old_slug, exercise.git_type, old_sha, repo: repo)
    end

    memoize
    def new_git
      Git::Exercise.new(exercise.slug, exercise.git_type, exercise.git_sha, repo: repo)
    end

    memoize
    def repo
      Git::Repository.new(repo_url: exercise.track.repo_url)
    end

    Diff = Struct.new(:filepath, :filename, :diff)
    private_constant :Diff
  end
end
