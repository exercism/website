require "test_helper"

class User::GithubSolutionSyncer
  class SyncEverythingTest < ActiveSupport::TestCase
    test "noops when installation token returns 404" do
      user = create(:user)
      create(:user_github_solution_syncer, user:)

      GithubApp.stubs(:generate_installation_token!).raises(GithubApp::InstallationNotFoundError)

      # Should not raise
      User::GithubSolutionSyncer::SyncEverything.(user)
    end

    test "noops when integration lacks permission" do
      user = create(:user)
      create(:user_github_solution_syncer, user:)

      CreatePullRequest.stubs(:call).raises(Octokit::Forbidden)

      # Should not raise
      User::GithubSolutionSyncer::SyncEverything.(user)
    end

    test "noops when git command fails" do
      user = create(:user)
      create(:user_github_solution_syncer, user:)

      CreatePullRequest.stubs(:call).raises(RuntimeError, "Command failed with exit 1: git")

      # Should not raise
      User::GithubSolutionSyncer::SyncEverything.(user)
    end

    test "requeues on server error" do
      user = create(:user)
      create(:user_github_solution_syncer, user:)

      CreatePullRequest.stubs(:call).raises(Octokit::ServerError)

      Mocha::Configuration.override(stubbing_non_existent_method: :allow) do
        cmd = User::GithubSolutionSyncer::SyncEverything.new(user)
        cmd.expects(:requeue_job!).with(30.seconds)
        cmd.()
      end
    end
  end
end
