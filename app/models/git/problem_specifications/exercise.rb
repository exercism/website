class Git::ProblemSpecifications::Exercise
  extend Mandate::Memoize
  extend Mandate::InitializerInjector
  extend Git::HasGitFilepath

  delegate :head_sha, :lookup_commit, :head_commit, to: :repo

  git_filepath :deprecated, file: ".deprecated"
  git_filepath :canonical_data, file: "canonical-data.json"
  git_filepath :description, file: "description.md"
  git_filepath :instructions, file: "instructions.md"
  git_filepath :introduction, file: "introduction.md"
  git_filepath :metadata, file: "metadata.toml"

  attr_reader :slug

  def initialize(slug, repo_url: Git::ProblemSpecifications::DEFAULT_REPO_URL, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
    @slug = slug
  end

  memoize
  def title = metadata["title"]

  memoize
  def blurb = metadata["blurb"]

  memoize
  def source = metadata["source"]

  memoize
  def source_url = metadata["source_url"]

  memoize
  def deep_dive_youtube_id = metadata["deep_dive_youtube_id"]

  memoize
  def deep_dive_blurb = metadata["deep_dive_blurb"]

  memoize
  def deprecated? = deprecated_exists?

  memoize
  def description_html
    return Markdown::Parse.(description) if description.present?

    Markdown::Parse.(introduction.to_s) + Markdown::Parse.(instructions.to_s)
  end

  memoize
  def absolute_filepaths = filepaths.map { |filepath| absolute_filepath(filepath) }
  def filepaths = file_entries.map { |defn| defn[:full] }
  def dir = "exercises/#{slug}"

  private
  attr_reader :repo

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
  def commit = repo.lookup_commit(repo.head_sha)
end
