class User::GithubSolutionSyncer
  class ProcessIteration
    include Mandate

    initialize_with :iteration

    def call
      return unless syncer

      if syncer.commit_to_main?
        CreateCommit.(iteration, syncer.main_branch_name)
      else
        CreatePR.(iteration)
      end
    end

    memoize
    def syncer = context.user.github_solution_syncer
  end
end
