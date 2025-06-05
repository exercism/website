class User::GithubSolutionSyncer
  class CreatePullRequest
    include Mandate

    def initialize(syncer, pr_title, pr_message, &commit_block)
      @syncer = syncer
      @pr_title = pr_title
      @pr_message = pr_message
      @commit_block = commit_block
    end

    def call
      new_branch = "exercism-sync/#{SecureRandom.hex(8)}"
      client.create_ref(repo_full_name, "heads/#{new_branch}", base_sha)

      commits_created = commit_block.(new_branch, token)
      return unless commits_created

      client.create_pull_request(
        repo_full_name,
        base_branch,
        new_branch,
        pr_title,
        pr_message
      )
    end

    private
    attr_reader :syncer, :pr_title, :pr_message, :commit_block

    delegate :repo_full_name, to: :syncer

    memoize
    def base_sha
      # This will raise if the branch doesn't exit
      client.branch(repo_full_name, base_branch).commit.sha
    rescue Octokit::NotFound
      # If it doesn't, then this is a naked repo, so create it.
      Dir.mktmpdir do |dir|
        @path = dir

        # No existing branch so create it
        git "init", "-b", base_branch
        git "commit", "--allow-empty", "-m", "Initial empty commit"
        git "remote", "add", "origin", repo_url
        git "push", "origin", base_branch
      end

      client.branch(repo_full_name, base_branch).commit.sha
    end

    memoize
    def base_branch = client.repository(repo_full_name).default_branch

    def git(*args)
      Dir.chdir(@path) do
        system("git", *args, exception: true)
      end
    end

    def repo_url = "https://x-access-token:#{token}@github.com/#{repo_full_name}.git"

    memoize
    def token = GithubApp.generate_installation_token!(syncer.installation_id)

    memoize
    def client = Octokit::Client.new(access_token: token)
  end
end
