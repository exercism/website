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
  end
end
