module Git
  class Track
    extend Mandate::Memoize
    extend Git::HasGitFilepaths

    delegate :head_sha, :fetch!, :lookup_commit, :head_commit, to: :repo

    git_filepaths about: "docs/ABOUT.md",
                  snippet: "docs/SNIPPET.txt",
                  debug: "exercises/shared/.docs/debug.md",
                  help: "exercises/shared/.docs/help.md",
                  tests: "exercises/shared/.docs/tests.md",
                  config: "config.json"

    def initialize(git_sha = "HEAD", repo_url: nil, repo: nil)
      raise "One of :repo or :repo_url must be specified" unless [repo, repo_url].compact.size == 1

      @repo = repo || Repository.new(repo_url: repo_url)
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
    def commit
      repo.lookup_commit(git_sha)
    end

    def full_filepath(filepath)
      filepath
    end

    private
    attr_reader :repo, :git_sha

    delegate :read_text_blob, :read_json_blob, to: :repo
  end
end
