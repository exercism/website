class User::GithubSolutionSyncer
  class SyncSolution
    include Mandate

    initialize_with :solution

    def call
      return unless syncer&.enabled?

      if syncer.commit_to_main?
        sync_iterations(syncer.main_branch_name)
      else
        pr_title = GeneratePullRequestTitle.(syncer, "Solution", exercise:)
        CreatePullRequest.(syncer, pr_title, pr_message) do |pr_branch_name, token|
          sync_iterations(pr_branch_name, token)
        end
      end
    rescue GithubApp::InstallationNotFoundError
      # noop - installation may have been removed or GitHub may be having issues
    rescue Octokit::Forbidden
      # noop - the integration no longer has permission to access the repo
    rescue Octokit::ServerError
      requeue_job!(30.seconds)
    end

    private
    delegate :user, :exercise, :track, to: :solution

    def sync_iterations(branch_name, token = nil)
      # Note if any of these are successful!
      results = solution.iterations.map do |iteration|
        files = FilesForIteration.(syncer, iteration)
        commit_message = GenerateCommitMessage.(syncer, iteration)

        CreateCommit.(syncer, files, commit_message, branch_name, token:)
      end

      # Don't inline this else it exits early
      results.any?
    end

    memoize
    def syncer = user.github_solution_syncer

    def pr_message
      desc = "This is a sync of all of %<handle>s's iterations on the [#{exercise.title}](https://exercism.org/tracks/#{track.slug}/exercises/#{exercise.slug}) exercise on [Exercism's](https://exercism.org) [#{track.title} Track](https://exercism.org/tracks/#{track.slug})." # rubocop:disable Layout/LineLength
      GeneratePullRequestMessage.(user, desc)
    end
  end
end
