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
  end
end
