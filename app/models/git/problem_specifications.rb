class Git::ProblemSpecifications
  extend Mandate::Memoize

  DEFAULT_REPO_URL = "https://github.com/exercism/problem-specifications".freeze

  def self.update! = new.update!

  def initialize(repo_url: DEFAULT_REPO_URL)
    @repo = Git::Repository.new(repo_url:)
  end

  def update! = repo.fetch!

  memoize
  def active_exercise_slugs
    exercise_dir_entries.filter_map do |entry|
      entry[:name] unless deprecated_exercise?(entry)
    end
  end

  private
  attr_reader :repo

  delegate :head_commit, to: :repo

  def deprecated_exercise?(entry)
    repo.file_exists?(repo.head_commit, "exercises/#{entry[:name]}/.deprecated")
  end

  memoize
  def exercise_dir_entries
    repo.fetch_tree(repo.head_commit, "exercises").select { |entry| entry[:type] == :tree }
  end
end
