class Git::Representer
  extend Mandate::Memoize
  extend Git::HasGitFilepath

  git_filepath :config, file: "config.json"

  def initialize(repo_url: nil, repo: nil)
    raise "One of :repo or :repo_url must be specified" unless [repo, repo_url].compact.size == 1

    @repo = repo || Git::Repository.new(repo_url:)
  end

  memoize
  def version = config[:version] || 1

  memoize
  def commit = repo.head_commit

  def absolute_filepath(filepath) = filepath

  private
  attr_reader :repo, :git_sha
end
