module Git
  class Track
    # TODO: Slug can be removed from this
    # once we're out of the monorepo
    def initialize(url, slug)
      @repo = Git::Repository.new(url)
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

    def exercise(slug, sha)
      commit = repo.lookup_commit(sha)
      Git::Exercise.new(
        repo, slug, commit,
        config(commit: commit)
      )
    end

    def config(commit: repo.head_commit)
      repo.read_json_blob(commit, "languages/#{slug}/config.json")
    end

    private
    attr_reader :repo, :slug
  end
end
