class Git::BootcampContent
  extend Mandate::Memoize

  DEFAULT_REPO_URL = "git@github.com:exercism/bootcamp-content.git".freeze

  attr_reader :repo

  def self.update! = new.update!

  def initialize(repo_url: DEFAULT_REPO_URL, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
  end

  def update! = repo.fetch!

  memoize
  def levels
    Git::BootcampContent::Levels.new(repo:)
  end

  memoize
  def projects
    project_dir_entries.map do |entry|
      Git::BootcampContent::Project.new(entry[:name], repo:)
    end
  end

  memoize
  def concepts
    Git::BootcampContent::Concepts.new(repo:)
  end

  private
  delegate :head_commit, to: :repo

  memoize
  def project_dir_entries
    repo.fetch_tree(repo.head_commit, "projects").select { |entry| entry[:type] == :tree }
  end
end
