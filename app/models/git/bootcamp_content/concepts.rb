class Git::BootcampContent::Concepts
  extend Mandate::Memoize
  extend Mandate::InitializerInjector
  extend Git::HasGitFilepath

  delegate :head_sha, :lookup_commit, :head_commit, to: :repo

  git_filepath :config, file: "config.json"

  def initialize(repo_url: Git::BootcampContent::DEFAULT_REPO_URL, repo: nil)
    @repo = repo || Git::Repository.new(repo_url:)
  end

  memoize
  def concepts
    concept_documents.map do |entry|
      concept_config = config.find { |config| config[:slug] == File.basename(entry[:name], ".*") }
      Git::BootcampContent::Concept.new(
        concept_config,
        repo:
      )
    end
  end

  def each(&block) = concepts.each(&block)

  private
  delegate :head_commit, to: :repo
  attr_reader :repo

  memoize
  def concept_documents
    repo.fetch_tree(repo.head_commit, dir).select { |entry| entry[:type] == :blob && File.extname(entry[:name]) == ".md" }
  end

  def absolute_filepath(filepath) = "#{dir}/#{filepath}"

  memoize
  def commit = repo.lookup_commit(repo.head_sha)

  memoize
  def absolute_filepaths = filepaths.map { |filepath| absolute_filepath(filepath) }
  def filepaths = file_entries.map { |defn| defn[:full] }
  def dir = "concepts"
end
