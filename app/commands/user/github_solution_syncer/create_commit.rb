class User::GithubSolutionSyncer
  class CreateCommit
    include Mandate

    initialize_with :iteration, :branch_name, token: nil

    def call
      base_branch = client.branch(repo, branch_name.to_s)
      base_commit_sha = base_branch.commit.sha
      base_tree_sha = base_branch.commit.commit.tree.sha

      # Build a tree with all the new/updated files
      tree = files.map do |filename, content|
        {
          path: "#{path}/#{filename}",
          mode: "100644",
          type: "blob",
          content:
        }
      end

      new_tree = client.create_tree(repo, tree, base_tree: base_tree_sha)
      new_commit = client.create_commit(repo, commit_message, new_tree.sha, base_commit_sha)
      client.update_ref(repo, "heads/#{branch_name}", new_commit.sha)
    end

    private
    delegate :user, :exercise, :track, to: :iteration

    def files
      iteration.submission.files.each_with_object({}) do |file, hash|
        hash[file.filename] = file.content
      end
    end

    memoize
    def commit_message = GenerateCommitMessage.(iteration)

    memoize
    def path
      syncer.path_template.
        gsub("$track_title", track.title).
        gsub("$track_slug", track.slug).
        gsub("$exercise_title", exercise.title).
        gsub("$exercise_slug", exercise.slug).
        gsub("$iteration_idx", iteration.idx.to_s).
        gsub("//", "/").
        gsub(%r{/$}, "")
    end

    memoize
    def syncer = user.github_solution_syncer
    def repo = syncer.repo_full_name

    memoize
    def client = Octokit::Client.new(access_token: token)

    memoize
    def token
      @token || GithubApp.generate_installation_token!(syncer.installation_id)
    end
  end
end
