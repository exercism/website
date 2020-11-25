module Git
  class Track
    extend Mandate::Memoize

    delegate :head_sha, :update!, :lookup_commit, :head_commit, to: :repo

    def initialize(slug, git_sha = "HEAD", repo_url: nil, repo: nil)
      raise "One of :repo or :repo_url must be specified" unless [repo, repo_url].compact.size == 1

      @repo = repo || Repository.new(slug, repo_url: repo_url)
      @slug = slug
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
    def config
      repo.read_json_blob(commit, config_filepath)
    end

    def config_filepath
      "languages/#{slug}/config.json"
    end

    memoize
    def commit
      repo.lookup_commit(git_sha)
    end

    private
    attr_reader :repo, :slug, :git_sha
  end
end
