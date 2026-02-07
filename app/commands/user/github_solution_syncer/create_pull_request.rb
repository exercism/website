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
        base_branch_name,
        new_branch,
        pr_title,
        pr_message
      )
    rescue Octokit::NotFound
      # Repo may have been deleted or renamed — nothing to sync to
      nil
    end

    private
    attr_reader :syncer, :pr_title, :pr_message, :commit_block

    delegate :repo_full_name, to: :syncer

    memoize
    def base_sha = FindOrCreateBranch.(repo_full_name, base_branch_name, token).commit.sha

    memoize
    def base_branch_name = client.repository(repo_full_name).default_branch

    memoize
    def token = GithubApp.generate_installation_token!(syncer.installation_id)

    memoize
    def client = Octokit::Client.new(access_token: token)
  end
end
