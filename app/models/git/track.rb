module Git
  class Track

    def initialize(url)
      @repo = Git::Repository.new(url)
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

    def exercise(slug, sha)
      commit = repo.lookup_commit(sha)
      Git::Exercise.new(
        repo, slug, commit,
        config(commit: commit)
      )
    end

    def config(commit: repo.head_commit)
      repo.read_json_blob(commit, 'languages/ruby/config.json')
    end

    private
    attr_reader :repo
  end
end
