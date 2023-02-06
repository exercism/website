class Git::Exercise::Articles
  extend Mandate::Memoize
  extend Mandate::InitializerInjector
  extend Git::HasGitFilepath

  delegate :head_sha, :lookup_commit, :head_commit, to: :repo

  git_filepath :config, file: "config.json"

  def initialize(exercise_slug, exercise_type, git_sha = "HEAD", repo_url: nil, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
    @exercise_slug = exercise_slug
    @exercise_type = exercise_type
    @git_sha = git_sha
  end

  def synced_git_sha = commit.oid

  memoize
  def articles = config[:articles].to_a

  memoize
  def absolute_filepaths
    filepaths.map { |filepath| absolute_filepath(filepath) }
  end

  def filepaths = file_entries.map { |defn| defn[:full] }

  def read_file_blob(filepath)
    mapped = file_entries.map { |f| [f[:full], f[:oid]] }.to_h
    mapped[filepath] ? repo.read_blob(mapped[filepath]) : nil
  end

  def dir = "exercises/#{exercise_type}/#{exercise_slug}/.articles"

  private
  attr_reader :repo, :exercise_slug, :exercise_type, :git_sha

  def absolute_filepath(filepath) = "#{dir}/#{filepath}"

  memoize
  def file_entries
    tree.walk(:preorder).map do |root, entry|
      next if entry[:type] == :tree

      entry[:full] = "#{root}#{entry[:name]}"
      entry
    end.compact
  rescue Rugged::TreeError
    []
  end

  memoize
  def tree = repo.fetch_tree(commit, dir)

  memoize
  def commit = repo.lookup_commit(git_sha)
end
