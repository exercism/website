module Git
  class Blog
    extend Mandate::Memoize

    REPO_NAME = "exercism/blog".freeze
    DEFAULT_REPO_URL = "https://github.com/#{REPO_NAME}".freeze

    def self.content_for(slug)
      new.content_for(slug)
    end

    def self.update!
      new.update!
    end

    def initialize(repo_url: DEFAULT_REPO_URL)
      @repo = Repository.new(repo_url:)
    end

    memoize
    def config
      repo.read_json_blob(repo.head_commit, "config.json")
    end

    def content_for(slug)
      filepath = "posts/#{slug}.md"
      repo.read_text_blob(head_commit, filepath)
    end

    def update!
      repo.fetch!
    end

    private
    attr_reader :repo

    delegate :head_commit, to: :repo
  end
end
