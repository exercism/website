class User::GithubSolutionSyncer
  class SyncTrack
    include Mandate

    initialize_with :user_track

    def call
      return unless syncer&.enabled?

      if syncer.commit_to_main?
        sync_solutions(syncer.main_branch_name)
      else
        pr_title = GeneratePullRequestTitle.(syncer, "Track", track:)
        CreatePullRequest.(syncer, pr_title, pr_message) do |pr_branch_name, token|
          sync_solutions(pr_branch_name, token)
        end
      end
    end

    private
    delegate :user, :track, to: :user_track

    def sync_solutions(branch_name, token = nil)
      repo = LocalGitRepo.new(syncer, syncer.main_branch_name, branch_name, token:)

      solutions = user_track.solutions.
        includes(:track, exercise: [:track], iterations: [{ submission: :files }, :exercise, :track])

      num_commits = 0
      repo.update do
        # Note if any of these are successful!
        solutions.each do |solution|
          solution.iterations.each do |iteration|
            files = FilesForIteration.(syncer, iteration)
            next unless files.any?(&:present?)

            files.each { |f| repo.write_file(f[:path], f[:content]) }
            commit_message = GenerateCommitMessage.(syncer, iteration)
            repo.commit_all(commit_message)
            num_commits += 1
          end
        end
      end

      num_commits.positive?
    end

    memoize
    def syncer = user.github_solution_syncer

    def pr_message
      desc = "This is a batch sync of all of %<handle>s's solutions on [Exercism's](https://exercism.org) the [#{track.title} Track](https://exercism.org/tracks/#{track.slug})."
      GeneratePullRequestMessage.(user, desc)
    end
  end
end
