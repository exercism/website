class User::GithubSolutionSyncer
  class SyncEverything
    include Mandate

    initialize_with :user

    def call
      return unless syncer

      if syncer.commit_to_main?
        sync_everything(syncer.main_branch_name)
      else
        pr_title = GeneratePullRequestTitle.(syncer, "Solution", exercise:)
        pr_message = "[Exercism] Batch sync of solution #{solution.track.title} | #{solution.exercise.title}"
        CreatePullRequest.(syncer, pr_title, pr_message) do |pr_branch_name, token|
          sync_everything(pr_branch_name, token)
        end
      end
    end

    private
    def sync_everything(branch_name, token = nil)
      # Note if any of these are successful!
      results = user.user_tracks.map do |user_track|
        track_results = user_track.solutions.map do |solution|
          iteration_results = solution.iterations.map do |iteration|
            files = FilesForIteration.(syncer, iteration)
            commit_message = GenerateCommitMessage.(syncer, iteration)

            CreateCommit.(syncer, files, commit_message, branch_name, token:)
          end
          iteration_results.any?
        end
        track_results.any?
      end

      # Don't inline this else it exits early
      results.any?
    end

    memoize
    def syncer = user.github_solution_syncer
  end
end
