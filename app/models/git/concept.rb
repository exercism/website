module Git
  class Concept
    extend Mandate::Memoize
    extend Git::HasGitFilepath

    delegate :head_sha, :head_commit, to: :repo

    git_filepath :about, file: "about.md"
    git_filepath :introduction, file: "introduction.md"
    git_filepath :links, file: "links.json"
    git_filepath :config, file: ".meta/config.json"

    def initialize(concept_slug, git_sha = "HEAD", repo_url: nil, repo: nil)
      @repo = repo || Repository.new(repo_url:)
      @concept_slug = concept_slug
      @git_sha = git_sha
    end

    memoize
    def authors
      config[:authors].to_a
    end

    memoize
    def contributors
      config[:contributors].to_a
    end

    memoize
    def links
      repo.read_json_blob(commit, absolute_filepath(links_filepath)).map { |link| OpenStruct.new(link) }
    end

    memoize
    def blurb
      config[:blurb]
    end

    def synced_git_sha = commit.oid

    private
    attr_reader :repo, :concept_slug, :git_sha

    def absolute_filepath(filepath) = "#{dir}/#{filepath}"
    def dir = "concepts/#{concept_slug}"

    memoize
    def commit
      repo.lookup_commit(git_sha)
    end
  end
end
