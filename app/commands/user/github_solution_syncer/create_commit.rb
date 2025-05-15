class User::GithubSolutionSyncer::CreateCommit
  include Mandate

  initialize_with :iteration, :branch_name

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
  def commit_message = process_template(syncer.commit_message_template)

  memoize
  def path = process_template(syncer.path_template).gsub(%r{/$}, "")

  def process_template(template)
    template.
      gsub("$track_title", track.title).
      gsub("$track_slug", track.slug).
      gsub("$exercise_title", exercise.title).
      gsub("$exercise_slug", exercise.slug).
      gsub("$iteration_idx", iteration.idx.to_s).
      gsub("//", "/")
  end

  memoize
  def syncer = user.github_solution_syncer
  def repo = syncer.repo_full_name

  memoize
  def client = Octokit::Client.new(access_token: token)

  memoize
  def token
    User::GithubSolutionSyncer::GithubApp.generate_installation_token!(syncer.installation_id)
  end
end
