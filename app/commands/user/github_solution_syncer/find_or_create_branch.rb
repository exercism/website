class User::GithubSolutionSyncer
  class FindOrCreateBranch
    include Mandate

    initialize_with :repo_full_name, :branch_name, :token

    def call
      # This will raise if the branch doesn't exit
      client.branch(repo_full_name, branch_name)
    rescue Octokit::NotFound
      # If it doesn't, then this is a naked repo, so create it.
      WithGitContext.() do |git|
        # No existing branch so create it
        git.("init", "-b", branch_name)

        # Make sure we have the right user set
        git.("config", "user.name", "Exercism's Solution Syncer Bot")
        git.("config", "user.email", "211797793+exercism-solutions-syncer[bot]@users.noreply.github.com")

        # Make an empty commit and push it
        git.("commit", "--allow-empty", "-m", "Initial empty commit")
        git.("remote", "add", "origin", repo_url)
        git.("push", "origin", branch_name)
      end

      client.branch(repo_full_name, branch_name)
    end

    private
    def repo_url = "https://x-access-token:#{token}@github.com/#{repo_full_name}.git"

    memoize
    def client = Octokit::Client.new(access_token: token)
  end
end
