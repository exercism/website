require "test_helper"

class User::GithubSolutionSyncer
  class CreatePullRequestTest < ActiveSupport::TestCase
    test "creates pull request" do
      pr_title = "Some title"
      pr_body = "Update Two Fer solution"
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

      block = ->(_, _) {}
      block.expects(:call).with(new_branch, token).returns(true)

      client.expects(:create_pull_request).with(
        syncer.repo_full_name,
        base_branch,
        new_branch,
        pr_title,
        pr_body
      )

      User::GithubSolutionSyncer::CreatePullRequest.(syncer, pr_title, pr_body, &block)
    end
  end
end
