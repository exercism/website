class User::GithubSolutionSyncer
  class CreatePullRequest
    include Mandate

    def initialize(syncer, pr_title, &commit_block)
      @syncer = syncer
      @pr_title = pr_title
      @commit_block = commit_block
    end

    def call
      repo = syncer.repo_full_name
      client = Octokit::Client.new(access_token: token)

      base_branch = client.repository(repo).default_branch
      base_sha = client.branch(repo, base_branch).commit.sha

      new_branch = "exercism-sync/#{SecureRandom.hex(8)}"
      client.create_ref(repo, "heads/#{new_branch}", base_sha)

      commits_created = commit_block.(new_branch, token)
      return unless commits_created

      client.create_pull_request(
        repo,
        base_branch,
        new_branch,
        pr_title,
        "This is an automatic sync from Exercism (https://exercism.org)."
      )
    end

    private
    attr_reader :syncer, :pr_title, :commit_block

    memoize
    def token
      GithubApp.generate_installation_token!(syncer.installation_id)
    end
  end
end
