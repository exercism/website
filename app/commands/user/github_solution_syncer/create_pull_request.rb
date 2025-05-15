class User::GithubSolutionSyncer
  class CreatePullRequest
    include Mandate

    initialize_with :iteration

    def call
      repo = syncer.repo_full_name
      client = Octokit::Client.new(access_token: token)

      base_branch = client.repository(repo).default_branch
      base_sha = client.branch(repo, base_branch).commit.sha

      new_branch = "exercism-sync/#{exercise.slug}-#{SecureRandom.hex(4)}"
      client.create_ref(repo, "heads/#{new_branch}", base_sha)

      # Reuse your existing logic to create a commit on this new branch
      CreateCommit.(iteration, new_branch, token:)

      client.create_pull_request(
        repo,
        base_branch,
        new_branch,
        pr_title,
        "This is an automatic sync from Exercism (https://exercism.org)."
      )
    end

    private
    delegate :user, :exercise, to: :iteration

    memoize
    def syncer = user.github_solution_syncer

    memoize
    def pr_title = GenerateCommitMessage.(iteration)

    memoize
    def token
      GithubApp.generate_installation_token!(syncer.installation_id)
    end
  end
end
