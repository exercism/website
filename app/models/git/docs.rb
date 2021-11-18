module Git
  class Docs
    extend Mandate::Memoize

    DEFAULT_REPO_URL = "https://github.com/exercism/docs".freeze

    def initialize(repo_url: DEFAULT_REPO_URL)
      @repo = Repository.new(repo_url: repo_url)
    end

    def section_config(section)
      repo.read_json_blob(repo.head_commit, "#{section}/config.json")
    end

    private
    attr_reader :repo
  end
end
