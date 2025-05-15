class User::GithubSolutionSyncer
  class ProcessIteration
    include Mandate

    initialize_with :iteration

    def call
      return unless syncer

      if syncer.commit_to_main?
        CreateCommit.(iteration, syncer.main_branch_name)
      else
        CreatePullRequest.(iteration)
      end
    end

    memoize
    def syncer = iteration.user.github_solution_syncer
  end
end
