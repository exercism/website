require "test_helper"

class User::GithubSolutionSyncer
  class CreateCommitTest < ActiveSupport::TestCase
    test "creates commit for iteration" do
      user = create(:user)
      track = create(:track, title: "Ruby", slug: "ruby")
      exercise = create(:practice_exercise, title: "Two Fer", slug: "two-fer", track:)
      solution = create(:practice_solution, user:, exercise:)
      submission = create(:submission)
      create(:submission_file, submission:, filename: "two_fer.rb", file_contents: "puts 'hi'")
      create(:submission_file, submission:, filename: "README.md", file_contents: "# Two Fer")
      iteration = create(:iteration, user:, solution:, idx: 3, submission:)

      syncer = create(:user_github_solution_syncer,
        user:,
        repo_full_name: "jeremy/exercism-solutions",
        installation_id: 1234,
        commit_message_template: "Add $exercise_slug$ solution",
        path_template: "solutions/$track_slug/$exercise_slug/$iteration_idx")

      token = "fake-token"
      GithubApp.stubs(generate_installation_token!: token)

      # Set up stubbed GitHub responses
      repo = syncer.repo_full_name
      branch_name = "main"
      branch_url = "https://api.github.com/repos/#{repo}/branches/#{branch_name}"
      tree_url = "https://api.github.com/repos/#{repo}/git/trees"
      commit_url = "https://api.github.com/repos/#{repo}/git/commits"
      ref_url = "https://api.github.com/repos/#{repo}/git/refs/heads/#{branch_name}"

      # 1. Fetch branch
      stub_request(:get, branch_url).to_return(
        status: 200,
        body: {
          commit: {
            sha: "base-commit-sha",
            commit: {
              tree: {
                sha: "base-tree-sha"
              }
            }
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

      # 2. Create tree
      stub_request(:post, tree_url).to_return(
        status: 201,
        body: { sha: "new-tree-sha" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

      # 3. Create commit
      stub_request(:post, commit_url).to_return(
        status: 201,
        body: { sha: "new-commit-sha" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

      # 4. Update ref
      stub_request(:patch, ref_url).to_return(
        status: 200,
        body: {}.to_json,
        headers: { "Content-Type" => "application/json" }
      )

      files = User::GithubSolutionSyncer::FilesForIteration.(syncer, iteration)
      commit_message = "my first commit"
      User::GithubSolutionSyncer::CreateCommit.(syncer, files, commit_message, branch_name)

      assert_requested :get, branch_url
      assert_requested :post, tree_url do |req|
        body = JSON.parse(req.body)
        files = body["tree"].map { |f| f["path"] }
        assert_includes files, "solutions/ruby/two-fer/3/two_fer.rb"
        assert_includes files, "solutions/ruby/two-fer/3/README.md"
      end
      assert_requested :post, commit_url
      assert_requested :patch, ref_url
    end
  end
end
