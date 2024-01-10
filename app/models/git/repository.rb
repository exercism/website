module Git
  class MissingCommitError < RuntimeError
  end

  class Repository
    extend Mandate::Memoize

    MAIN_BRANCH_REF = "main".freeze

    def initialize(repo_url: nil, branch_ref: nil)
      @repo_name = repo_url.split("/").last

      if Rails.env.development? && ENV["GIT_CONTENT_REPO"].present?
        @repo_url = ENV["GIT_CONTENT_REPO"]
      elsif repo_url
        @repo_url = repo_url
      elsif Rails.env.test?
        @repo_url = "file://#{Rails.root / 'test' / 'repos' / 'track'}"
      else
        @repo_url = repo_url || "https://github.com/exercism/#{repo_name}"
      end

      @branch_ref = branch_ref || ENV["GIT_CONTENT_BRANCH"].presence || MAIN_BRANCH_REF

      fetch! if keep_up_to_date?
    end

    def head_commit = active_branch.target
    def head_sha = head_commit.oid

    def read_json_blob(commit, path)
      raw = read_file_blob(commit, path, "{}")
      JSON.parse(raw, symbolize_names: true)
    end

    def read_toml_blob(commit, path)
      raw = read_file_blob(commit, path, "")
      TOML.load(raw)
    end

    def read_text_blob(commit, path)
      read_file_blob(commit, path, "")
    end

    def read_file_blob(commit, path, default = nil)
      oid = find_file_oid(commit, path)
      read_blob(oid, default)
    rescue Rugged::TreeError
      default
    end

    def read_blob(oid, default = nil)
      blob = lookup(oid)
      blob.present? ? blob.text : default
    end

    def lookup_commit(sha, update_on_failure: true)
      return head_commit if sha == "HEAD"

      lookup(sha).tap do |object|
        raise 'wrong-type' if object.type != :commit
      end
    rescue Rugged::OdbError, Rugged::InvalidError
      raise MissingCommitError unless update_on_failure

      fetch!
      lookup_commit(sha, update_on_failure: false)
    end

    def file_exists?(commit, path)
      !!commit.tree.path(path)
    rescue Rugged::TreeError
      false
    end

    def file_last_modified_at(path)
      walker = Rugged::Walker.new(rugged_repo)
      walker.sorting(Rugged::SORT_DATE)
      walker.push(head_commit.oid)
      last_commit = walker.find do |commit|
        commit.parents.size == 1 && commit.diff(paths: [path]).size.positive?
      end
      last_commit.time
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

    def fetch!
      system("cd #{repo_dir} && git fetch --force origin #{branch_ref}:#{branch_ref}", out: File::NULL, err: File::NULL)
    rescue Rugged::NetworkError => e
      # Don't block development offline
      Rails.logger.info e.message
    end

    private
    attr_reader :repo_name, :repo_url, :branch_ref

    def active_branch
      rugged_repo.branches[branch_ref]
    end

    def repo_dir
      return "#{repos_dir}/test/#{repo_url.gsub(/[^a-z0-9]/, '')}" if Rails.env.test?

      "#{repos_dir}/#{repo_name}"
    end

    memoize
    def repos_dir
      return "./test/tmp/git_repo_cache" if Rails.env.test?

      Exercism.config.efs_repositories_mount_point
    end

    memoize
    def rugged_repo
      unless File.directory?(repo_dir)
        cmd = [
          "git clone",
          "--bare",
          "-c core.sharedRepository=true",
          ("--single-branch" if branch_ref == MAIN_BRANCH_REF),
          repo_url,
          repo_dir
        ].join(" ")
        system(cmd)

        fetch!
      end

      Rugged::Repository.new(repo_dir)
    rescue StandardError => e
      Rails.logger.error "Failed to clone repo #{repo_url}"
      Rails.logger.error e.message
      raise
    end

    # If we're in dev or test mode we want to just fetch
    # every time to get up to date. In production
    # we schedule this based off webhooks instead
    memoize
    def keep_up_to_date?
      Rails.env.test? || !!ENV["GIT_ALWAYS_FETCH_ORIGIN"]
    end
  end
end
