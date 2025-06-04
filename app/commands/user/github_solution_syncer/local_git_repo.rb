class User::GithubSolutionSyncer
  class LocalGitRepo
    extend Mandate::Memoize

    def initialize(syncer, base_branch_name, new_branch_name, token: nil)
      @syncer = syncer
      @base_branch_name = base_branch_name
      @new_branch_name = new_branch_name
      @token = token
    end

    def update
      return false if repo_too_big?

      Dir.mktmpdir do |dir|
        @path = dir
        clone_repo
        create_branch
        yield self if block_given?
        push_branch
      end

      true
    end

    def write_file(path, content)
      full_path = File.join(@path, path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, content)
    end

    def commit_all(message)
      return if `git -C #{@path} status --porcelain`.strip.empty?

      git("add", ".")
      git("commit", "-m", message)
    end

    def branch_name = @new_branch_name

    def base_branch_name
      client.branch(repo, @base_branch_name)
      @base_branch_name
    rescue Octokit::NotFound
      client.repository(repo).default_branch
    end

    private
    attr_reader :syncer, :new_branch_name

    def repo = syncer.repo_full_name

    def clone_repo
      git("clone", "--depth=1", "--branch=#{base_branch_name}", repo_url, ".")
    end

    def create_branch
      existing = `git -C #{@path} branch --list #{new_branch_name}`.strip
      if existing.empty?
        git("checkout", "-b", new_branch_name)
      else
        git("checkout", new_branch_name)
      end
    end

    def push_branch
      git("push", "--set-upstream", "origin", new_branch_name)
    end

    def git(*args)
      Dir.chdir(@path) do
        system("git", *args, exception: true)
      end
    end

    def repo_url
      "https://x-access-token:#{token}@github.com/#{repo}.git"
    end

    def token
      @token ||= GithubApp.generate_installation_token!(syncer.installation_id)
    end

    def repo_too_big?
      size_kb = Octokit::Client.new(access_token: token).repository(repo).size
      size_kb > 10_000 # 10MB
    end

    memoize
    def client
      Octokit::Client.new(access_token: token)
    end
  end
end
