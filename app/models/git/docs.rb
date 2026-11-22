module Git
  class Docs
    extend Mandate::Memoize

    delegate :head_sha, :fetch!, to: :repo

    DEFAULT_REPO_URL = Repository.default_url_for("docs").freeze

    def initialize(repo_url: DEFAULT_REPO_URL, branch_ref: nil)
      @repo = Repository.new(repo_url:, branch_ref:)
    end

    def section_config(section)
      repo.read_json_blob(repo.head_commit, "#{section}/config.json")
    end

    private
    attr_reader :repo
  end
end
