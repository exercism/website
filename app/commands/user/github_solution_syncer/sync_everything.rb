class User::GithubSolutionSyncer
  class SyncEverything
    include Mandate

    initialize_with :user

    def call
      return unless syncer

      if syncer.commit_to_main?
        sync_everything(syncer.main_branch_name)
      else
        pr_title = GeneratePullRequestTitle.(syncer, "Everything")
        CreatePullRequest.(syncer, pr_title, pr_message) do |pr_branch_name, token|
          sync_everything(pr_branch_name, token)
        end
      end
    end

    def sync_everything(branch_name, token = nil)
      repo = LocalGitRepo.new(syncer, syncer.main_branch_name, branch_name, token:)

      user_tracks = user.user_tracks.includes(solutions: [:track, {
        exercise: [:track], iterations: [{ submission: :files }, :exercise, :track]
      }])

      num_commits = 0
      repo.update do
        # Note if any of these are successful!
        user_tracks.each do |user_track|
          user_track.solutions.each do |solution|
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
      end

      num_commits.positive?
    end

    memoize
    def syncer = user.github_solution_syncer

    def pr_message
      desc = "This is a batch sync of all of %<handle>s's solutions on [Exercism](https://exercism.org)."
      GeneratePullRequestMessage.(user, desc)
    end
  end
end
