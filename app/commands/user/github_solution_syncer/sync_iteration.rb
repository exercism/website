class User::GithubSolutionSyncer
  class SyncIteration
    include Mandate

    initialize_with :iteration

    def call
      return unless syncer

      files = FilesForIteration.(iteration)
      commit_message = GenerateCommitMessage.(iteration)

      if syncer.commit_to_main?
        CreateCommit.(syncer, files, commit_message, syncer.main_branch_name)
      else
        CreatePullRequest.(syncer, files, commit_message)
      end
    end

    memoize
    def syncer = iteration.user.github_solution_syncer
  end
end
