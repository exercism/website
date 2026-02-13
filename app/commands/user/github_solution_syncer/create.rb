class User::GithubSolutionSyncer::Create
  include Mandate

  initialize_with :user, :installation_id do
    raise GithubSolutionSyncerCreationError, "Missing installation ID" unless installation_id.present?
  end

  def call
    user.github_solution_syncer&.destroy

    user.create_github_solution_syncer!(
      installation_id:,
      repo_full_name: repo.full_name
    )
  rescue User::GithubSolutionSyncer::GithubApp::InstallationNotFoundError
    raise GithubSolutionSyncerCreationError, "GitHub App installation not found or no longer accessible"
  rescue Octokit::Unauthorized
    raise GithubSolutionSyncerCreationError, "GitHub authorization failed"
  rescue Octokit::Error => e
    raise GithubSolutionSyncerCreationError, "GitHub API error: #{e.message}"
  end

  private
  memoize
  def client = Octokit::Client.new(access_token: token)

  memoize
  def repo
    repos = client.list_app_installation_repositories.repositories
    raise GithubSolutionSyncerCreationError, "Please grant access to exactly one repository" unless repos.size == 1

    repos.first
  end

  memoize
  def token
    User::GithubSolutionSyncer::GithubApp.generate_installation_token!(installation_id).tap do |token|
      raise GithubSolutionSyncerCreationError, "Failed to retrieve GitHub installation token" if token.blank?
    end
  end
end
