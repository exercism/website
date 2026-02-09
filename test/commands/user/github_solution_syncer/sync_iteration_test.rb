require "test_helper"

class User::GithubSolutionSyncer
  class SyncIterationTest < ActiveSupport::TestCase
    test "noops when installation token returns 404" do
      user = create(:user)
      track = create(:track, slug: "ruby")
      exercise = create(:practice_exercise, track:, slug: "two-fer")
      solution = create(:practice_solution, user:, exercise:)
      submission = create(:submission, solution:)
      iteration = create(:iteration, user:, solution:, submission:)
      create(:user_github_solution_syncer, user:)

      GithubApp.stubs(:generate_installation_token!).raises(GithubApp::InstallationNotFoundError)

      # Should not raise
      User::GithubSolutionSyncer::SyncIteration.(iteration)
    end

    test "requeues on server error" do
      user = create(:user)
      track = create(:track, slug: "ruby")
      exercise = create(:practice_exercise, track:, slug: "two-fer")
      solution = create(:practice_solution, user:, exercise:)
      submission = create(:submission, solution:)
      iteration = create(:iteration, user:, solution:, submission:)
      create(:user_github_solution_syncer, user:)

      CreatePullRequest.stubs(:call).raises(Octokit::ServerError)

      Mocha::Configuration.override(stubbing_non_existent_method: :allow) do
        cmd = User::GithubSolutionSyncer::SyncIteration.new(iteration)
        cmd.expects(:requeue_job!).with(30.seconds)
        cmd.()
      end
    end
  end
end
