class User::GithubSolutionSyncer
  class SyncTrack
    include Mandate

    initialize_with :user_track

    def call
      return unless syncer

      if syncer.commit_to_main?
        sync_solutions(syncer.main_branch_name)
      else
        pr_title = GeneratePullRequestTitle.(syncer, "Solution", exercise:)
        pr_message = "[Exercism] Batch sync of solution #{solution.track.title} | #{solution.exercise.title}"
        CreatePullRequest.(syncer, pr_title, pr_message) do |pr_branch_name, token|
          sync_solutions(pr_branch_name, token)
        end
      end
    end

    private
    delegate :user, :track, to: :user_track

    def sync_solutions(branch_name, token = nil)
      # Note if any of these are successful!
      results = track.solutions.map do |solution|
        it_results = solution.iterations.map do |iteration|
          files = FilesForIteration.(syncer, iteration)
          commit_message = GenerateCommitMessage.(syncer, iteration)

          CreateCommit.(syncer, files, commit_message, branch_name, token:)
        end

        # Don't inline this else it exits early
        it_results.any?
      end

      # Don't inline this else it exits early
      results.any?
    end

    memoize
    def syncer = user.github_solution_syncer
  end
end
