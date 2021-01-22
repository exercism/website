module Git
  class Track
    extend Mandate::Memoize

    delegate :head_sha, :fetch!, :lookup_commit, :head_commit, to: :repo

    def initialize(slug, git_sha = "HEAD", repo_url: nil, repo: nil)
      raise "One of :repo or :repo_url must be specified" unless [repo, repo_url].compact.size == 1

      @repo = repo || Repository.new(slug, repo_url: repo_url)
      @git_sha = git_sha
    end

    def test_regexp
      pattern = config[:test_pattern]
      Regexp.new(pattern.presence || "[tT]est")
    end

    def ignore_regexp
      pattern = config[:ignore_pattern]
      Regexp.new(pattern.presence || "[iI]gnore")
    end

    memoize
    def key_features
      config[:key_features].to_a
    end

    memoize
    def about
      repo.read_text_blob(commit, about_filepath)
    end

    memoize
    def snippet
      repo.read_text_blob(commit, snippet_filepath)
    end

    memoize
    def config
      repo.read_json_blob(commit, config_filepath)
    end

    def about_filepath
      "docs/ABOUT.md"
    end

    def snippet_filepath
      "docs/SNIPPET.txt"
    end

    def config_filepath
      "config.json"
    end

    memoize
    def commit
      repo.lookup_commit(git_sha)
    end

    private
    attr_reader :repo, :git_sha
  end
end
