module Git
  class Exercise
    extend Mandate::Memoize
    extend Mandate::InitializerInjector
    extend Git::HasGitFilepath

    delegate :head_sha, :lookup_commit, :head_commit, to: :repo
    delegate :introduction, :introduction_last_modified_at, :introduction_exists?, :introduction_edit_url, to: :approaches,
      prefix: true

    git_filepath :instructions, file: ".docs/instructions.md", append_file: ".docs/instructions.append.md"
    git_filepath :introduction, file: ".docs/introduction.md", append_file: ".docs/introduction.append.md"
    git_filepath :instructions_append, file: ".docs/instructions.append.md"
    git_filepath :introduction_append, file: ".docs/introduction.append.md"
    git_filepath :hints, file: ".docs/hints.md"
    git_filepath :config, file: ".meta/config.json"

    SPECIAL_FILEPATHS = {
      config: '.exercism/config.json',
      readme: 'README.md',
      hints: 'HINTS.md',
      help: 'HELP.md'
    }.freeze

    def self.for_solution(solution, git_sha: nil)
      new(
        solution.git_slug,
        solution.git_type,
        git_sha || solution.git_sha,
        repo_url: solution.track.repo_url
      )
    end

    def initialize(exercise_slug, exercise_type, git_sha = "HEAD", repo_url: nil, repo: nil)
      @repo = repo || Repository.new(repo_url:)
      @exercise_slug = exercise_slug
      @exercise_type = exercise_type
      @git_sha = git_sha
    end

    def synced_git_sha = commit.oid

    def valid_submission_filepath?(filepath)
      return false if filepath.match?(%r{[^a-zA-Z0-9_./-]})
      return false if filepath.starts_with?(".meta/")
      return false if filepath.starts_with?(".docs/")
      return false if filepath.starts_with?(".approaches/")
      return false if filepath.starts_with?(".articles/")
      return false if filepath.starts_with?(".exercism/")

      # We don't want to let students override the editor files
      return false if editor_filepaths.include?(filepath)

      # We don't want to let students override the test files. However, some languages
      # have solutions and tests in the same file so we need the second guard for that.
      return false if test_filepaths.include?(filepath) && solution_filepaths.exclude?(filepath)

      true
    end

    memoize
    def authors
      config[:authors].to_a
    end

    memoize
    def contributors
      config[:contributors].to_a
    end

    memoize
    def source
      config[:source]
    end

    memoize
    def source_url
      config[:source_url]
    end

    memoize
    def blurb
      config[:blurb]
    end

    memoize
    def icon_name
      config[:icon] || exercise_slug.to_s
    end

    memoize
    def has_test_runner?
      config.fetch(:test_runner, true)
    end

    memoize
    def representer_version = representer[:version] || 1

    memoize
    def representer = config[:representer] || {}

    memoize
    def solution_filepaths
      config.dig(:files, :solution).to_a
    end

    memoize
    def test_filepaths
      config.dig(:files, :test).to_a
    end

    memoize
    def editor_filepaths
      config.dig(:files, :editor).to_a
    end

    memoize
    def invalidator_filepaths
      config.dig(:files, :invalidator).to_a
    end

    memoize
    def exemplar_filepaths
      config.dig(:files, :exemplar).to_a
    end

    memoize
    def example_filepaths
      config.dig(:files, :example).to_a
    end

    memoize
    def exemplar_files
      exemplar_filepaths.index_with do |filepath|
        read_file_blob(filepath)
      end
    rescue StandardError
      {}
    end

    memoize
    def example_files
      example_filepaths.index_with do |filepath|
        read_file_blob(filepath)
      end
    rescue StandardError
      {}
    end

    def test_files
      test_filepaths.index_with do |filepath|
        read_file_blob(filepath)
      end
    rescue StandardError
      {}
    end

    # Files that should be transported
    # to a user for use in the editor.
    memoize
    def files_for_editor
      files = {}

      solution_filepaths.each do |filepath|
        files[filepath] = { type: :exercise, content: read_file_blob(filepath) }
      end

      editor_filepaths.each do |filepath|
        files[filepath] = { type: :readonly, content: read_file_blob(filepath) }
      end

      files
    rescue StandardError
      {}
    end

    # This includes meta files
    memoize
    def tooling_files
      tooling_filepaths.each.with_object({}) do |filepath, hash|
        hash[filepath] = read_file_blob(filepath)
      end
    end

    # This includes meta files, but excludes docs files
    memoize
    def tooling_filepaths
      filepaths.reject do |filepath|
        filepath.starts_with?(".docs/") ||
          filepath.starts_with?(".approaches/") ||
          filepath.starts_with?(".articles/")
      end
    end

    # This includes meta files, but excludes docs files
    memoize
    def tooling_absolute_filepaths
      tooling_filepaths.map { |filepath| absolute_filepath(filepath) }
    end

    memoize
    def important_files
      important_filepaths.each.with_object({}) do |filepath, hash|
        hash[filepath] = read_file_blob(filepath)
      end
    end

    memoize
    def important_filepaths
      [
        instructions_filepath,
        instructions_append_filepath,
        introduction_filepath,
        introduction_append_filepath,
        hints_filepath,
        *test_filepaths,
        *editor_filepaths,
        *invalidator_filepaths
      ].select do |filepath|
        filepaths.include?(filepath)
      end
    end

    memoize
    def important_absolute_filepaths
      important_filepaths.map { |filepath| absolute_filepath(filepath) }
    end

    memoize
    def cli_filepaths
      special_filepaths = SPECIAL_FILEPATHS.values_at(:config, :readme, :help)
      special_filepaths << SPECIAL_FILEPATHS[:hints] if filepaths.include?(hints_filepath)

      filtered_filepaths = filepaths.select do |filepath|
        next if filepath.start_with?('.docs/')
        next if filepath.start_with?('.meta/')
        next if filepath.start_with?('.approaches/')
        next if filepath.start_with?('.articles/')
        next if example_filepaths.include?(filepath)
        next if exemplar_filepaths.include?(filepath)

        true
      end

      special_filepaths.concat(filtered_filepaths)
    end

    def read_file_blob(filepath)
      mapped = file_entries.map { |f| [f[:full], f[:oid]] }.to_h
      mapped[filepath] ? repo.read_blob(mapped[filepath]) : nil
    end

    def dir = "exercises/#{exercise_type}/#{exercise_slug}"

    memoize
    def approaches = Git::Exercise::Approaches.new(exercise_slug, exercise_type, git_sha, repo:)

    memoize
    def articles = Git::Exercise::Articles.new(exercise_slug, exercise_type, git_sha, repo:)

    memoize
    def no_important_files_changed? = commit.message.downcase.include?(NO_IMPORTANT_FILES_CHANGED)

    private
    attr_reader :repo, :exercise_slug, :exercise_type, :git_sha

    def absolute_filepath(filepath) = "#{dir}/#{filepath}"

    def filepaths
      file_entries.map { |defn| defn[:full] }
    end

    memoize
    def file_entries
      tree.walk(:preorder).map do |root, entry|
        next if entry[:type] == :tree

        entry[:full] = "#{root}#{entry[:name]}"
        entry
      end.compact
    end

    memoize
    def tree = repo.fetch_tree(commit, dir)

    memoize
    def commit = repo.lookup_commit(git_sha)

    memoize
    def track = Track.new(repo:)

    NO_IMPORTANT_FILES_CHANGED = "[no important files changed]".freeze
    private_constant :NO_IMPORTANT_FILES_CHANGED
  end
end
