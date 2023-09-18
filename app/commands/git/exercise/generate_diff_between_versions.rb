class Git::Exercise::GenerateDiffBetweenVersions
  include Mandate

  initialize_with :exercise, :old_slug, :old_sha

  def call
    changed_files.filter_map do |cf|
      next unless interesting_paths.include?(cf.filepath)

      {
        relative_path: cf.relative_path,
        diff: cf.diff
      }
    end
  end

  private
  def changed_files = changed_in_git + changed_in_config

  memoize
  def changed_in_git
    # This is a diff of two commits considering all files in the respective old and new directories
    raw_diff = `cd #{repo_dir} && git diff #{old_sha} #{exercise.git_sha} -- #{old_git.dir} #{new_git.dir}`

    ProcessDiff.(raw_diff, exercise)
  end

  memoize
  def changed_in_git_filepaths = changed_in_git.map(&:filepath)

  memoize
  def changed_in_config
    changed_in_config_filepaths.flat_map do |filepath|
      raw_diff = `cd #{repo_dir} && git diff #{first_sha} #{exercise.git_sha} -- #{filepath}`
      ProcessDiff.(raw_diff, exercise)
    end
  end

  memoize
  def changed_in_config_filepaths = new_interesting_paths - changed_in_git_filepaths

  memoize
  def first_sha = `cd #{repo_dir} && git rev-list HEAD | tail -n 1`.strip

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
  def old_git = Git::Exercise.new(old_slug, exercise.git_type, old_sha, repo:)

  memoize
  def new_git = Git::Exercise.new(exercise.slug, exercise.git_type, exercise.git_sha, repo:)

  memoize
  def repo = Git::Repository.new(repo_url: exercise.track.repo_url)

  memoize
  def repo_dir = repo.send(:repo_dir)

  class ProcessDiff
    include Mandate

    initialize_with :raw_diff, :exercise

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
      @diffs << Diff.new(filepath, exercise.git_dir, lines.join) if filepath
    end

    Diff = Struct.new(:filepath, :dir, :diff) do
      def relative_path = filepath[dir.size + 1..]
    end
    private_constant :Diff
  end
end
