class User::GithubSolutionSyncer
  class CreateCommit
    include Mandate

    # Expects files to be an array of hashes, with the
    # keys path, mode, type and content.
    initialize_with :syncer, :files, :commit_message, :branch_name, token: nil

    def call
      return false unless files.present?

      base_branch = client.branch(repo, branch_name.to_s)
      base_commit_sha = base_branch.commit.sha
      base_tree_sha = base_branch.commit.commit.tree.sha

      new_tree = client.create_tree(repo, files, base_tree: base_tree_sha)

      # If the tree hasn't changed, we don't create the commit and return false
      # so that anything upstream can be aware
      return false if new_tree.sha == base_tree_sha

      new_commit = client.create_commit(repo, commit_message, new_tree.sha, base_commit_sha)
      client.update_ref(repo, "heads/#{branch_name}", new_commit.sha)

      # Let's keep this as always a boolean response.
      true
    end

    private
    memoize
    def repo = syncer.repo_full_name

    memoize
    def client = Octokit::Client.new(access_token: token)

    memoize
    def token
      @token || GithubApp.generate_installation_token!(syncer.installation_id)
    end
  end
end
