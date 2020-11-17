module Git
  class Repository
    extend Mandate::Memoize

    def initialize(repo_name, repo_url: nil)
      @repo_name = repo_name

      @repo_url =
        if ENV["GIT_CONTENT_REPO"].present?
          ENV["GIT_CONTENT_REPO"]
        elsif repo_url
          repo_url
        elsif Rails.env.test?
          # TODO; Switch when we move back out of monorepo
          "file://#{(Rails.root / 'test' / 'repos' / 'v3-monorepo')}"
        else
          # TODO; Switch when we move back out of monorepo
          # @repo_url = repo_url || "https://github.com/exercism/#{repo_name}"
          "https://github.com/exercism/v3"
        end

      update! if keep_up_to_date?
    end

    def head_commit
      active_branch.target
    end

    def read_json_blob(commit, path)
      oid = find_file_oid(commit, path)
      raw = read_blob(oid, "{}")
      JSON.parse(raw, symbolize_names: true)
    end

    def read_blob(oid, default = nil)
      blob = lookup(oid)
      blob.present? ? blob.text : default
    end

    def lookup_commit(oid, update_on_failure: true)
      return head_commit if oid == "HEAD"

      lookup(oid).tap do |object|
        raise 'wrong-type' if object.type != :commit
      end
    rescue Rugged::OdbError
      raise 'not-found' unless update_on_failure

      update!
      lookup_commit(oid, update_on_failure: false)
    end

    def find_file_oid(commit, path)
      entry = commit.tree.path(path)
      raise "Not a blob" if entry[:type] != :blob

      entry[:oid]
    end

    def fetch_tree(commit, path)
      entry = commit.tree.path(path)
      raise "Not a tree" if entry[:type] != :tree

      lookup(entry[:oid])
    end

    def lookup(*args)
      rugged_repo.lookup(*args)
    end

    def update!
      system("cd #{repo_dir} && git fetch origin master:master", out: File::NULL, err: File::NULL)
    rescue Rugged::NetworkError => e
      # Don't block development offline
      Rails.logger.info e.message
    end

    private
    attr_reader :repo_name, :repo_url

    def active_branch
      rugged_repo.branches[branch_ref]
    end

    def repo_dir
      # TODO: Change when breaking out of monorepo
      "#{repos_dir}/#{Digest::SHA1.hexdigest(repo_url)}-v3"
      # "#{repos_dir}/#{Digest::SHA1.hexdigest(repo_url)}-#{repo_name}"
    end

    memoize
    def repos_dir
      return "./test/tmp/git_repo_cache" if Exercism.env.test?
      return "./tmp/git_repo_cache" if Exercism.env.development?

      "/mnt/repos"
    end

    memoize
    def rugged_repo
      unless File.directory?(repo_dir)
        cmd = [
          "git clone",
          "--bare",
          ("--single-branch" if branch_ref == MAIN_BRANCH_REF),
          repo_url,
          repo_dir
        ].join(" ")
        system(cmd)

        update!
      end

      Rugged::Repository.new(repo_dir)
    rescue StandardError => e
      Rails.logger.error "Failed to clone repo #{repo_url}"
      Rails.logger.error e.message
      raise
    end

    # If we're in dev or test mode we want to just fetch
    # every time to get up to date. In production
    # we schedule this based of webhooks instead
    memoize
    def keep_up_to_date?
      # TODO: Add a test for this env var
      Rails.env.test? || !!ENV["GIT_ALWAYS_FETCH_ORIGIN"]
    end

    memoize
    def branch_ref
      # TODO: Add a test for this.
      ENV["GIT_CONTENT_BRANCH"].presence || MAIN_BRANCH_REF
    end

    MAIN_BRANCH_REF = "master".freeze
    private_constant :MAIN_BRANCH_REF
  end
end
