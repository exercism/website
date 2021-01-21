module Git
  class Exercise
    extend Mandate::Memoize
    extend Mandate::InitializerInjector

    delegate :head_sha, :lookup_commit, :head_commit, to: :repo

    def self.for_solution(solution)
      new(
        solution.track.slug,
        solution.git_slug,
        solution.git_type,
        "HEAD" # TODO: Change to solution.git_sha once we let users update exercises
      )
    end

    # TODO: repo_url can be removed once we're out of a monorepo
    def initialize(track_slug, exercise_slug, exercise_type, git_sha = "HEAD", repo_url: nil, repo: nil)
      @repo = repo || Repository.new(track_slug, repo_url: repo_url)
      @track_slug = track_slug
      @exercise_slug = exercise_slug
      @exercise_type = exercise_type
      @git_sha = git_sha
    end

    def normalised_git_sha
      commit.oid
    end

    memoize
    def instructions
      read_file_blob(".docs/instructions.md")
    end

    memoize
    def introduction
      read_file_blob(".docs/introduction.md")
    end

    memoize
    def hints
      read_file_blob(".docs/hints.md")
    rescue StandardError
      nil
    end

    # TODO: This is stub code
    memoize
    def example
      read_file_blob(filepaths.find { |fp| fp.downcase.include?("example.") })
    rescue StandardError
      "No example code found"
    end

    memoize
    def authors
      config[:authors]
    end

    memoize
    def contributors
      config[:contributors]
    end

    # Files that should be transported
    # to a user for use in the editor.
    memoize
    def editor_solution_files
      config[:editor][:solution_files].index_with do |filepath|
        read_file_blob(filepath)
      end
    rescue StandardError
      {}
    end

    # This includes meta files
    memoize
    def non_ignored_files
      non_ignored_filepaths.each.with_object({}) do |filepath, hash|
        hash[filepath] = read_file_blob(filepath)
      end
    end

    # This includes meta files
    memoize
    def non_ignored_filepaths
      filepaths.select do |filepath| # rubocop:disable Style/InverseMethods
        !filepath.match?(track.ignore_regexp)
      end
    end

    # This includes meta files
    memoize
    def non_ignored_absolute_filepaths
      non_ignored_filepaths.map { |filepath| full_filepath(filepath) }
    end

    def read_file_blob(filepath)
      mapped = file_entries.map { |f| [f[:full], f[:oid]] }.to_h
      mapped[filepath] ? repo.read_blob(mapped[filepath]) : nil
    end

    def dir
      # TODO: Needs changing once we're out of the monorepo
      "languages/#{track_slug}/exercises/#{exercise_type}/#{exercise_slug}"
    end

    private
    attr_reader :repo, :track_slug, :exercise_slug, :exercise_type, :git_sha

    def full_filepath(filepath)
      "#{dir}/#{filepath}"
    end

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
    def tree
      # TODO: When things are exploded back into repos, do this
      # repo.fetch_tree(commit, "exercises/#{exercise_type}/#{slug}")
      repo.fetch_tree(commit, dir)
    end

    memoize
    def config
      HashWithIndifferentAccess.new(
        JSON.parse(read_file_blob('.meta/config.json'))
      )
    end

    memoize
    def commit
      repo.lookup_commit(git_sha)
    end

    memoize
    def track
      Track.new(track_slug, repo: repo)
    end
  end
end
