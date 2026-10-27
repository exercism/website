class User::GithubSolutionSyncer::Create
  include Mandate

  initialize_with :user, :installation_id do
    raise GithubSolutionSyncerCreationError, "Missing installation ID" unless installation_id.present?
    raise GithubSolutionSyncerCreationError, "Invalid installation ID" unless installation_id.to_s.match?(/\A\d+\z/)
  end

  def call
    verify_installation_account!

    user.github_solution_syncer&.destroy

    user.create_github_solution_syncer!(
      installation_id:,
      repo_full_name: repo.full_name
    )
  rescue User::GithubSolutionSyncer::GithubApp::InstallationNotFoundError
    raise GithubSolutionSyncerCreationError, "GitHub App installation not found or no longer accessible"
  rescue Octokit::Unauthorized
    raise GithubSolutionSyncerCreationError, "GitHub authorization failed"
  rescue Octokit::Error, RestClient::Exception => e
    raise GithubSolutionSyncerCreationError, "GitHub API error: #{e.message}"
  end

  private
  # The installation must be on the personal GitHub account that is
  # linked to this Exercism account. We compare GitHub's numeric account
  # id (stored as the user's uid when they connect GitHub), as it stays
  # the same if the user renames their GitHub account.
  def verify_installation_account!
    unless github_uid.present?
      raise GithubSolutionSyncerCreationError,
        "Please connect your GitHub account to Exercism before setting up the GitHub Syncer"
    end

    account = installation["account"] || {}

    if account["type"] != "User"
      raise GithubSolutionSyncerCreationError,
        "The GitHub Syncer only supports personal GitHub accounts. Please install it on your own GitHub account"
    end

    return if account["id"].to_s == github_uid

    raise GithubSolutionSyncerCreationError,
      "This GitHub App was installed on a different GitHub account to the one connected to your Exercism account"
  end

  def github_uid
    return nil unless user.provider == "github"

    user.uid.to_s
  end

  memoize
  def installation = User::GithubSolutionSyncer::GithubApp.fetch_installation!(installation_id)

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
