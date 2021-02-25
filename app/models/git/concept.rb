module Git
  class Concept
    extend Mandate::Memoize
    extend Git::HasGitFilepaths

    delegate :head_sha, :head_commit, to: :repo

    git_filepaths about: "about.md",
                  introduction: "introduction.md",
                  links: "links.json"

    def initialize(concept_slug, git_sha = "HEAD", repo_url: nil, repo: nil)
      @repo = repo || Repository.new(repo_url: repo_url)
      @concept_slug = concept_slug
      @git_sha = git_sha
    end

    memoize
    def links
      repo.read_json_blob(commit, absolute_filepath(links_filepath)).map { |link| OpenStruct.new(link) }
    end

    def normalised_git_sha
      commit.oid
    end

    private
    attr_reader :repo, :concept_slug, :git_sha

    def absolute_filepath(filepath)
      "#{dir}/#{filepath}"
    end

    def dir
      "concepts/#{concept_slug}"
    end

    memoize
    def commit
      repo.lookup_commit(git_sha)
    end
  end
end
