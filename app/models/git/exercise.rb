module Git
  class Exercise
    extend Mandate::Memoize
    extend Mandate::InitializerInjector

    delegate :head_sha, :lookup_commit, :head_commit, to: :repo

    def self.for_solution(solution)
      new(
        solution.git_slug,
        solution.git_type,
        "HEAD", # TODO: Change to solution.git_sha once we let users update exercises,
        repo_url: solution.track.repo_url
      )
    end

    def initialize(exercise_slug, exercise_type, git_sha = "HEAD", repo_url: nil, repo: nil)
      @repo = repo || Repository.new(repo_url: repo_url)
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
    def instructions_append
      read_file_blob(".docs/instructions.append.md")
    end

    memoize
    def introduction
      read_file_blob(".docs/introduction.md")
    end

    memoize
    def introduction_append
      read_file_blob(".docs/introduction.append.md")
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

    memoize
    def source
      config[:source]
    end

    memoize
    def source_url
      config[:source_url]
    end

    # Files that should be transported
    # to a user for use in the editor.
    memoize
    def solution_files
      config[:files][:solution].index_with do |filepath|
        read_file_blob(filepath)
      end
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

    # This includes meta files
    memoize
    def tooling_filepaths
      filepaths.select do |filepath| # rubocop:disable Style/InverseMethods
        !filepath.match?(track.ignore_regexp)
      end
    end

    # This includes meta files
    memoize
    def tooling_absolute_filepaths
      tooling_filepaths.map { |filepath| full_filepath(filepath) }
    end

    memoize
    def cli_filepaths
      special_filepaths = ['README.md', 'HELP.md']
      special_filepaths << 'HINTS.md' if filepaths.include?('.docs/hints.md')

      filtered_filepaths = filepaths.select do |filepath| # rubocop:disable Style/InverseMethods
        !filepath.match?(track.ignore_regexp) &&
          !filepath.start_with?('.docs/') &&
          !filepath.start_with?('.meta/')
      end

      special_filepaths.concat(filtered_filepaths)
    end

    def read_file_blob(filepath)
      mapped = file_entries.map { |f| [f[:full], f[:oid]] }.to_h
      mapped[filepath] ? repo.read_blob(mapped[filepath]) : nil
    end

    def dir
      "exercises/#{exercise_type}/#{exercise_slug}"
    end

    private
    attr_reader :repo, :exercise_slug, :exercise_type, :git_sha

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
      Track.new(repo: repo)
    end
  end
end
