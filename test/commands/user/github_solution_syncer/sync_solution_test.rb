require "test_helper"

class User::GithubSolutionSyncer
  class SyncSolutionTest < ActiveSupport::TestCase
    test "noops when installation token returns 404" do
      user = create(:user)
      track = create(:track, slug: "ruby")
      exercise = create(:practice_exercise, track:, slug: "two-fer")
      solution = create(:practice_solution, user:, exercise:)
      create(:user_github_solution_syncer, user:)

      GithubApp.stubs(:generate_installation_token!).raises(GithubApp::InstallationNotFoundError)

      # Should not raise
      User::GithubSolutionSyncer::SyncSolution.(solution)
    end
  end
end
