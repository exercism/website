class Git::BootcampContent::Level
  extend Mandate::Memoize
  extend Mandate::InitializerInjector
  extend Git::HasGitFilepath

  delegate :head_sha, :lookup_commit, :head_commit, to: :repo

  git_filepath :content, file: "content.md"

  attr_reader :idx, :config

  def initialize(idx, config, repo_url: Git::BootcampContent::DEFAULT_REPO_URL, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
    @idx = idx
    @config = config
  end

  memoize
  def title = config[:title]
  def description = config[:description]

  private
  attr_reader :repo

  def absolute_filepath(filepath) = "#{dir}/#{filepath}"

  memoize
  def commit = repo.lookup_commit(repo.head_sha)

  memoize
  def absolute_filepaths = filepaths.map { |filepath| absolute_filepath(filepath) }
  def filepaths = file_entries.map { |defn| defn[:full] }
  def dir = "levels/#{idx}"
end
