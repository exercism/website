module Git
  class WebsiteCopy
    extend Mandate::Memoize

    DEFAULT_REPO_URL = "https://github.com/exercism/website-copy".freeze

    def initialize(repo_url: DEFAULT_REPO_URL)
      @repo = Repository.new(repo_url: repo_url)
    end

    def analysis_comment_for(code)
      filepath = "analyzer-comments/#{code.tr('.', '/')}.md"
      repo.read_text_blob(head_commit, filepath)
    end

    private
    attr_reader :repo

    delegate :head_commit, to: :repo
  end
end
