require "test_helper"

class User::GithubSolutionSyncer
  class CreateTest < ActiveSupport::TestCase
    test "creates syncer when exactly one repo is returned" do
      user = create(:user, provider: "github", uid: "5624255")
      installation_id = 123_456
      token = "mocked-token"
      repo_full_name = "jeremy/exercism-solutions"

      stub_installation(account_id: 5_624_255)
      GithubApp.stubs(generate_installation_token!: token)

      stub_request(:get, "https://api.github.com/installation/repositories").
        to_return(
          status: 200,
          body: {
            repositories: [
              { full_name: repo_full_name }
            ]
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      User::GithubSolutionSyncer::Create.(user, installation_id)

      syncer = user.reload.github_solution_syncer
      assert syncer
      assert_equal installation_id, syncer.installation_id
      assert_equal repo_full_name, syncer.repo_full_name
    end

    test "raises if multiple repos returned" do
      user = create(:user, provider: "github", uid: "5624255")
      installation_id = 123_456
      token = "mocked-token"

      stub_installation(account_id: 5_624_255)
      GithubApp.stubs(generate_installation_token!: token)

      stub_request(:get, "https://api.github.com/installation/repositories").
        to_return(
          status: 200,
          body: {
            repositories: [
              { full_name: "jeremy/exercism-solutions" },
              { full_name: "jeremy/another-repo" }
            ]
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      assert_raises GithubSolutionSyncerCreationError do
        User::GithubSolutionSyncer::Create.(user, installation_id)
      end
    end

    test "raises if token is nil" do
      user = create(:user, provider: "github", uid: "5624255")
      installation_id = 123_456

      stub_installation(account_id: 5_624_255)
      GithubApp.stubs(generate_installation_token!: nil)

      assert_raises GithubSolutionSyncerCreationError do
        User::GithubSolutionSyncer::Create.(user, installation_id)
      end
    end

    test "raises if installation_id is missing" do
      user = create(:user)

      assert_raises GithubSolutionSyncerCreationError do
        User::GithubSolutionSyncer::Create.(user, nil)
      end
    end

    test "raises GithubSolutionSyncerCreationError when installation is not found or forbidden" do
      user = create(:user, provider: "github", uid: "5624255")
      installation_id = 123_456

      GithubApp.stubs(:fetch_installation!).raises(
        GithubApp::InstallationNotFoundError, "GitHub App installation #{installation_id} not found or not accessible"
      )

      assert_raises GithubSolutionSyncerCreationError do
        User::GithubSolutionSyncer::Create.(user, installation_id)
      end
    end

    test "replaces existing syncer" do
      user = create(:user, provider: "github", uid: "5624255")
      old_syncer = create(
        :user_github_solution_syncer,
        user:,
        repo_full_name: "old/repo",
        installation_id: 1
      )

      installation_id = 999
      token = "new-token"
      repo_full_name = "jeremy/new-repo"

      stub_installation(account_id: 5_624_255)
      GithubApp.stubs(generate_installation_token!: token)

      stub_request(:get, "https://api.github.com/installation/repositories").
        to_return(
          status: 200,
          body: {
            repositories: [
              { full_name: repo_full_name }
            ]
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      User::GithubSolutionSyncer::Create.(user, installation_id)

      syncer = user.reload.github_solution_syncer
      refute_equal old_syncer.id, syncer.id
      assert_equal installation_id, syncer.installation_id
      assert_equal repo_full_name, syncer.repo_full_name
    end

    test "raises if installation_id is not numeric" do
      user = create(:user, provider: "github", uid: "5624255")

      assert_raises GithubSolutionSyncerCreationError do
        User::GithubSolutionSyncer::Create.(user, "123/../456")
      end
    end

    test "raises if the user has not connected their GitHub account" do
      user = create(:user, provider: nil, uid: nil)
      GithubApp.expects(:generate_installation_token!).never

      error = assert_raises GithubSolutionSyncerCreationError do
        User::GithubSolutionSyncer::Create.(user, 123_456)
      end

      assert_includes error.message, "connect your GitHub account"
      assert_nil user.reload.github_solution_syncer
    end

    test "raises if the installation is on a different GitHub account" do
      user = create(:user, provider: "github", uid: "5624255")
      stub_installation(account_id: 999_999)
      GithubApp.expects(:generate_installation_token!).never

      error = assert_raises GithubSolutionSyncerCreationError do
        User::GithubSolutionSyncer::Create.(user, 123_456)
      end

      assert_includes error.message, "different GitHub account"
      assert_nil user.reload.github_solution_syncer
    end

    test "raises if the installation is on an organization" do
      user = create(:user, provider: "github", uid: "5624255")
      stub_installation(account_id: 5_624_255, account_type: "Organization")
      GithubApp.expects(:generate_installation_token!).never

      error = assert_raises GithubSolutionSyncerCreationError do
        User::GithubSolutionSyncer::Create.(user, 123_456)
      end

      assert_includes error.message, "personal GitHub accounts"
      assert_nil user.reload.github_solution_syncer
    end

    test "keeps the existing syncer if the installation is on a different GitHub account" do
      user = create(:user, provider: "github", uid: "5624255")
      old_syncer = create(:user_github_solution_syncer, user:, repo_full_name: "old/repo", installation_id: 1)
      stub_installation(account_id: 999_999)

      assert_raises GithubSolutionSyncerCreationError do
        User::GithubSolutionSyncer::Create.(user, 123_456)
      end

      assert_equal old_syncer.id, user.reload.github_solution_syncer.id
    end

    private
    def stub_installation(account_id:, account_type: "User")
      GithubApp.stubs(:fetch_installation!).returns(
        { "id" => 123_456, "account" => { "id" => account_id, "login" => "someone", "type" => account_type } }
      )
    end
  end
end
