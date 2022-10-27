class Git::Exercise::Article
  extend Mandate::Memoize
  extend Mandate::InitializerInjector
  extend Git::HasGitFilepath

  delegate :head_sha, :lookup_commit, :head_commit, to: :repo

  git_filepath :content, file: "content.md"
  git_filepath :snippet, file: "snippet.md"

  def initialize(article_slug, exercise_slug, exercise_type, git_sha = "HEAD", repo_url: nil, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
    @article_slug = article_slug
    @exercise_slug = exercise_slug
    @exercise_type = exercise_type
    @git_sha = git_sha
  end

  memoize
  def absolute_filepaths
    filepaths.map { |filepath| absolute_filepath(filepath) }
  end

  def filepaths = file_entries.map { |defn| defn[:full] }

  def dir = "exercises/#{exercise_type}/#{exercise_slug}/.articles/#{article_slug}"

  private
  attr_reader :repo, :article_slug, :exercise_slug, :exercise_type, :git_sha

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
