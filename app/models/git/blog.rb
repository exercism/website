module Git
  class Blog
    extend Mandate::Memoize

    REPO_NAME = "exercism/blog".freeze
    DEFAULT_REPO_URL = "https://github.com/#{REPO_NAME}".freeze

    def self.post_content_for(slug) = new.post_content_for(slug)
    def self.story_content_for(slug) = new.story_content_for(slug)
    def self.update! = new.update!

    def initialize(repo_url: DEFAULT_REPO_URL)
      @repo = Repository.new(repo_url:)
    end

    memoize
    def config = repo.read_json_blob(repo.head_commit, "config.json")

    def post_content_for(slug) = content_for("posts", slug)
    def story_content_for(slug) = content_for("stories", slug)

    def content_for(dir, slug) = repo.read_text_blob(head_commit, "#{dir}/#{slug}.md")

    def update! = repo.fetch!

    private
    attr_reader :repo

    delegate :head_commit, to: :repo
  end
end
