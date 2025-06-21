class Git::ToolingInvoker
  extend Mandate::Memoize

  DEFAULT_REPO_URL = "https://github.com/exercism/tooling-invoker".freeze

  attr_reader :repo

  def self.update! = new.update!

  def initialize(repo_url: DEFAULT_REPO_URL, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
  end

  def update! = repo.fetch!
end
