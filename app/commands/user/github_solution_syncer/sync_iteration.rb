class User::GithubSolutionSyncer
  class SyncIteration
    include Mandate

    initialize_with :iteration

    def call
      return unless syncer&.enabled?

      files = FilesForIteration.(syncer, iteration)
      commit_message = GenerateCommitMessage.(syncer, iteration)

      if syncer.commit_to_main?
        CreateCommit.(syncer, files, commit_message, syncer.main_branch_name)
      else
        pr_title = GeneratePullRequestTitle.(syncer, "Iteration", iteration:)
        CreatePullRequest.(syncer, pr_title, pr_message) do |pr_branch_name, token|
          CreateCommit.(syncer, files, commit_message, pr_branch_name, token:)
        end
      end
    end

    private
    delegate :user, :exercise, :track, to: :iteration

    memoize
    def syncer = user.github_solution_syncer

    def pr_message
      desc = "This is a sync of %<handle>s's #{iteration.idx.ordinalize} iteration to the [#{exercise.title}](https://exercism.org/tracks/#{track.slug}/exercises/#{exercise.slug}) exercise on [Exercism's](https://exercism.org) [#{track.title} Track](https://exercism.org/tracks/#{track.slug})." # rubocop:disable Layout/LineLength
      GeneratePullRequestMessage.(user, desc)
    end
  end
end
