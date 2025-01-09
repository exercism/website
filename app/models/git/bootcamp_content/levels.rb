class Git::BootcampContent::Levels
  extend Mandate::Memoize
  extend Mandate::InitializerInjector
  extend Git::HasGitFilepath

  delegate :head_sha, :lookup_commit, :head_commit, to: :repo

  git_filepath :config, file: "config.json"

  def initialize(repo_url: Git::BootcampContent::DEFAULT_REPO_URL, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
  end

  memoize
  def levels
    level_dir_entries.map do |entry|
      level_config = config.find { |config| config[:idx] == entry[:name].to_i }
      Git::BootcampContent::Level.new(
        entry[:name],
        level_config,
        repo:
      )
    end
  end

  def each(&block) = levels.each(&block)

  private
  delegate :head_commit, to: :repo
  attr_reader :repo

  memoize
  def level_dir_entries
    repo.fetch_tree(repo.head_commit, "levels").select { |entry| entry[:type] == :tree }
  end

  def absolute_filepath(filepath) = "#{dir}/#{filepath}"

  memoize
  def commit = repo.lookup_commit(repo.head_sha)

  memoize
  def absolute_filepaths = filepaths.map { |filepath| absolute_filepath(filepath) }
  def filepaths = file_entries.map { |defn| defn[:full] }
  def dir = "levels"
end
