module Git
  class Blog
    extend Mandate::Memoize

    REPO_NAME = "exercism/blog".freeze
    DEFAULT_REPO_URL = "https://github.com/#{REPO_NAME}".freeze

    def self.post_content_for(slug) = new.post_content_for(slug)
    def self.update! = new.update!

    def initialize(repo_url: DEFAULT_REPO_URL)
      @repo = Repository.new(repo_url:)
    end

    memoize
    def config = repo.read_json_blob(repo.head_commit, "config.json")

    def post_content_for(slug) = content_for("posts", slug)

    def content_for(dir, slug)
      filepath = "#{dir}/#{slug}.md"
      repo.read_text_blob(head_commit, filepath)
    end

    def update! = repo.fetch!

    private
    attr_reader :repo

    delegate :head_commit, to: :repo
  end
end
