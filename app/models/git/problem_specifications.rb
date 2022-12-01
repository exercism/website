class Git::ProblemSpecifications
  extend Mandate::Memoize

  DEFAULT_REPO_URL = "https://github.com/exercism/problem-specifications".freeze

  attr_reader :repo

  def self.update! = new.update!

  def initialize(repo_url: DEFAULT_REPO_URL, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
  end

  def update! = repo.fetch!

  memoize
  def exercises
    exercise_dir_entries.map do |entry|
      Git::ProblemSpecifications::Exercise.new(entry[:name], repo:)
    end
  end

  private
  delegate :head_commit, to: :repo

  memoize
  def exercise_dir_entries
    repo.fetch_tree(repo.head_commit, "exercises").select { |entry| entry[:type] == :tree }
  end
end
