class User::GithubSolutionSyncer
  class SyncIteration
    include Mandate

    initialize_with :iteration

    def call
      return unless syncer

      files = FilesForIteration.(syncer, iteration)
      commit_message = GenerateCommitMessage.(syncer, iteration)

      if syncer.commit_to_main?
        CreateCommit.(syncer, files, commit_message, syncer.main_branch_name)
      else
        pr_title = GeneratePullRequestTitle.(syncer, "Iteration", iteration:)
        CreatePullRequest.(syncer, pr_title) do |pr_branch_name, token|
          CreateCommit.(syncer, files, commit_message, pr_branch_name, token:)
        end
      end
    end

    private
    delegate :user, to: :iteration

    memoize
    def syncer = user.github_solution_syncer
  end
end
