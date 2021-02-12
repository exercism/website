module Git
  class Concept
    extend Mandate::Memoize

    delegate :head_sha, :head_commit, to: :repo

    def initialize(concept_slug, git_sha = "HEAD", repo_url: nil, repo: nil)
      @repo = repo || Repository.new(repo_url: repo_url)
      @concept_slug = concept_slug
      @git_sha = git_sha
    end

    def read_file_blob(path)
      mapped = file_entries.map { |f| [f[:full], f[:oid]] }.to_h
      mapped[path] ? repo.read_blob(mapped[path]) : nil
    end

    memoize
    def about
      read_file_blob(FILEPATHS[:about])
    end

    memoize
    def introduction
      read_file_blob(FILEPATHS[:introduction])
    end

    memoize
    def links
      data = JSON.parse(read_file_blob(FILEPATHS[:links]))
      data.map { |link| OpenStruct.new(link) }
    end

    private
    attr_reader :repo, :concept_slug, :git_sha

    memoize
    def file_entries
      tree.walk(:preorder).map do |root, entry|
        next if entry[:type] == :tree

        entry[:full] = "#{root}#{entry[:name]}"
        entry
      end.compact
    end

    memoize
    def tree
      repo.fetch_tree(commit, "concepts/#{concept_slug}")
    end

    memoize
    def commit
      repo.lookup_commit(git_sha)
    end

    FILEPATHS = {
      about: "about.md",
      introduction: "introduction.md",
      links: "links.json"
    }.freeze
  end
end
