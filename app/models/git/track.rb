module Git
  class Track
    def initialize(url)
      @repo = Git::Repository.new(url)
    end

    def head_sha
      repo.head_commit.oid
    end

    # TODO: Read this from the repo
    def test_regexp
      pattern = config[:test_pattern]
      Regexp.new(pattern.present?? pattern : "[tT]est")
    end

    # TODO: Ignore pattern
    def ignore_regexp
      pattern = config[:ignore_pattern]
      Regexp.new(pattern.present?? pattern : "[iI]gnore")
    end

    def exercise(slug, sha)
      commit = repo.lookup_commit(sha)
      Git::Exercise.new(
        repo, slug, commit, 
        config(commit: commit)
      )
    end

    private
    attr_reader :repo

    def config(commit: repo.head_commit)
      config_pointer = commit.tree['config.json']
      repo.read_json_blob(config_pointer[:oid])
    end
  end
end

