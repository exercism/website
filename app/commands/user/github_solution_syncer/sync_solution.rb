class User::GithubSolutionSyncer
  class SyncSolution
    include Mandate

    initialize_with :solution

    def call
      return unless syncer

      if syncer.commit_to_main?
        sync_iterations(syncer.main_branch_name)
      else
        pr_title = GeneratePullRequestTitle.(syncer, "Solution", exercise:)
        pr_message = "[Exercism] Batch sync of solution #{solution.track.title} | #{solution.exercise.title}"
        CreatePullRequest.(syncer, pr_title, pr_message) do |pr_branch_name, token|
          sync_iterations(pr_branch_name, token)
        end
      end
    end

    private
    delegate :user, :exercise, :track, to: :solution

    def sync_iterations(branch_name, _token = nil)
      # Note if any of these are successful!
      results = solution.iterations.map do |iteration|
        files = FilesForIteration.(syncer, iteration)
        commit_message = GenerateCommitMessage.(syncer, iteration)

        CreateCommit.(syncer, files, commit_message, branch_name)
      end

      # Don't inline this else it exits early
      results.any?
    end

    memoize
    def syncer = user.github_solution_syncer
  end
end
