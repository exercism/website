require "test_helper"

class User::GithubSolutionSyncer
  class CreatePullRequestTest < ActiveSupport::TestCase
    test "creates pull request" do
      files = [
        {
          "path" => "solutions/ruby/two-fer/3/two_fer.rb",
          "mode" => "100644",
          "type" => "blob",
          "content" => "puts 'hi'"
        },
        {
          "path" => "solutions/ruby/two-fer/3/README.md",
          "mode" => "100644",
          "type" => "blob",
          "content" => "# Two Fer"
        }
      ]
      commit_message = "Update Two Fer solution"
      syncer = create :user_github_solution_syncer

      hex_8 = SecureRandom.hex(8)
      SecureRandom.expects(:hex).with(8).returns(hex_8)

      token = "fake-token-#{SecureRandom.uuid}"
      GithubApp.expects(:generate_installation_token!).with(syncer.installation_id).returns(token)

      client = mock
      Octokit::Client.expects(:new).with(access_token: token).returns(client)

      base_branch = "main"
      base_sha = "base-commit-sha"
      new_branch = "exercism-sync/#{hex_8}"
      client.expects(:repository).with(syncer.repo_full_name).returns(mock(default_branch: base_branch))
      client.expects(:branch).with(syncer.repo_full_name, base_branch).returns(mock(commit: mock(sha: base_sha)))
      client.expects(:create_ref).with(syncer.repo_full_name, "heads/#{new_branch}", base_sha)

      User::GithubSolutionSyncer::CreateCommit.expects(:call).with(
        files,
        commit_message,
        new_branch,
        token:
      )

      client.expects(:create_pull_request).with(
        syncer.repo_full_name,
        base_branch,
        new_branch,
        commit_message,
        "This is an automatic sync from Exercism (https://exercism.org)."
      )

      User::GithubSolutionSyncer::CreatePullRequest.(syncer, files, commit_message)
    end
  end
end
