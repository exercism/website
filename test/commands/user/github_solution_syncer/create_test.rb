require "test_helper"

class User::GithubSolutionSyncer
  class CreateTest < ActiveSupport::TestCase
    test "creates syncer when exactly one repo is returned" do
      user = create(:user)
      installation_id = 123_456
      token = "mocked-token"
      repo_full_name = "jeremy/exercism-solutions"

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
      user = create(:user)
      installation_id = 123_456
      token = "mocked-token"

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
      user = create(:user)
      installation_id = 123_456

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

    test "replaces existing syncer" do
      user = create(:user)
      old_syncer = create(
        :user_github_solution_syncer,
        user:,
        repo_full_name: "old/repo",
        installation_id: 1
      )

      installation_id = 999
      token = "new-token"
      repo_full_name = "jeremy/new-repo"

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
  end
end
