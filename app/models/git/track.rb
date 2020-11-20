module Git
  class Track
    def initialize(slug, repo_url: nil, repo: nil)
      raise "One of :repo or :repo_url must be specified" unless [repo, repo_url].compact.size == 1

      @repo = repo || Repository.new(slug, repo_url: repo_url)
      @slug = slug
    end

    def head_sha
      repo.head_commit.oid
    end

    def test_regexp
      pattern = config[:test_pattern]
      Regexp.new(pattern.presence || "[tT]est")
    end

    def ignore_regexp
      pattern = config[:ignore_pattern]
      Regexp.new(pattern.presence || "[iI]gnore")
    end

    def config(commit: repo.head_commit)
      repo.read_json_blob(commit, config_filepath)
    end

    def config_filepath
      "languages/#{slug}/config.json"
    end

    private
    attr_reader :repo, :slug
  end
end
