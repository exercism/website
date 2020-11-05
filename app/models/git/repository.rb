module Git
  class Repository
    extend Mandate::Memoize

    def initialize(repo_name, repo_url: nil)
      @repo_name = repo_name

      @repo_url = if repo_url
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
      main_branch.target
    end

    def read_json_blob(commit, path)
      oid = find_blob_oid(commit, path)
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

    def lookup_tree(oid)
      lookup(oid).tap do |object|
        raise 'wrong-type' if object.type != :tree
      end
    rescue Rugged::OdbError
      raise 'not-found'
    end

    def find_blob_oid(commit, path)
      parts = path.split('/')
      target_filename = parts.pop
      dir = "#{parts.join('/')}/"

      commit.tree.walk_blobs do |obj_dir, obj|
        return obj[:oid] if obj[:name] == target_filename && obj_dir == dir
      end

      raise "No blob found: #{target_filename}"
    end

    def read_tree(commit, path)
      parts = path.split("/")
      dir_name = parts.pop
      root_path = parts.present? ? "#{parts.join('/')}/" : ""

      commit.tree.walk_trees do |obj_dir, obj|
        return lookup(obj[:oid]) if obj_dir == root_path && obj[:name] == dir_name
      end

      raise "No blob found: #{path}"
    end

    def lookup(*args)
      rugged_repo.lookup(*args)
    end

    def update!
      system("cd #{repo_dir} && git fetch", out: File::NULL, err: File::NULL)
    rescue Rugged::NetworkError
      # Don't block development offline
    end

    private
    attr_reader :repo_name, :repo_url

    def main_branch
      rugged_repo.branches[MAIN_BRANCH_REF]
    end

    def repo_dir
      # TODO: Change when breaking out of monorepo
      "#{repos_dir}/#{Digest::SHA1.hexdigest(repo_url)}-#{repo_url.split('/').last}"
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
        `git clone --bare #{repo_url} #{repo_dir}`
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
    def keep_up_to_date?
      # TODO: Add a test for this env var
      Rails.env.test? || !!ENV["ALWAYS_FETCH_ORIGIN"]
    end

    def branch_ref
      # TODO: Add a test for this.
      ENV["GIT_CONTENT_BRANCH"].presence || MAIN_BRANCH_REF
    end

    MAIN_BRANCH_REF = "master".freeze
    private_constant :MAIN_BRANCH_REF
  end
end
