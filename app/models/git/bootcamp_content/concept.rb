class Git::BootcampContent::Concept
  extend Mandate::Memoize
  extend Mandate::InitializerInjector
  extend Git::HasGitFilepath

  delegate :head_sha, :lookup_commit, :head_commit, to: :repo

  attr_reader :config

  def initialize(config, repo_url: Git::BootcampContent::DEFAULT_REPO_URL, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
    @config = config
  end

  memoize
  def uuid = config[:uuid]
  def slug = config[:slug]
  def title = config[:title]
  def description = config[:description]
  def level = config[:level]
  def apex = !!config[:apex]
  def content = read_file_blob("#{slug}.md")

  private
  attr_reader :repo

  def absolute_filepath(filepath) = "#{dir}/#{filepath}"

  memoize
  def commit = repo.lookup_commit(repo.head_sha)

  memoize
  def absolute_filepaths = filepaths.map { |filepath| absolute_filepath(filepath) }
  def filepaths = file_entries.map { |defn| defn[:full] }
  def dir = "concepts"

  def read_file_blob(filepath)
    mapped = file_entries.map { |f| [f[:full], f[:oid]] }.to_h
    mapped[filepath] ? repo.read_blob(mapped[filepath]) : nil
  end
end
