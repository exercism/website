require "test_helper"

class User::GithubSolutionSyncer
  class SyncTrackTest < ActiveSupport::TestCase
    test "noops when installation token returns 404" do
      user = create(:user)
      track = create(:track, slug: "ruby")
      user_track = create(:user_track, user:, track:)
      create(:user_github_solution_syncer, user:)

      GithubApp.stubs(:generate_installation_token!).raises(GithubApp::InstallationNotFoundError)

      # Should not raise
      User::GithubSolutionSyncer::SyncTrack.(user_track)
    end

    test "noops when integration lacks permission" do
      user = create(:user)
      track = create(:track, slug: "ruby")
      user_track = create(:user_track, user:, track:)
      create(:user_github_solution_syncer, user:)

      CreatePullRequest.stubs(:call).raises(Octokit::Forbidden)

      # Should not raise
      User::GithubSolutionSyncer::SyncTrack.(user_track)
    end

    test "requeues on server error" do
      user = create(:user)
      track = create(:track, slug: "ruby")
      user_track = create(:user_track, user:, track:)
      create(:user_github_solution_syncer, user:)

      CreatePullRequest.stubs(:call).raises(Octokit::ServerError)

      Mocha::Configuration.override(stubbing_non_existent_method: :allow) do
        cmd = User::GithubSolutionSyncer::SyncTrack.new(user_track)
        cmd.expects(:requeue_job!).with(30.seconds)
        cmd.()
      end
    end
  end
end
