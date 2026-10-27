class User::GithubSolutionSyncer::Create
  include Mandate

  I18N_SCOPE = "commands.user_github_solution_syncer.create.errors".freeze

  initialize_with :user, :installation_id do
    raise GithubSolutionSyncerCreationError, error_message(:missing_installation_id) unless installation_id.present?
    raise GithubSolutionSyncerCreationError, error_message(:invalid_installation_id) unless installation_id.to_s.match?(/\A\d+\z/)
  end

  def call
    verify_installation_account!

    user.github_solution_syncer&.destroy

    user.create_github_solution_syncer!(
      installation_id:,
      repo_full_name: repo.full_name
    )
  rescue User::GithubSolutionSyncer::GithubApp::InstallationNotFoundError
    raise GithubSolutionSyncerCreationError, error_message(:installation_not_found)
  rescue Octokit::Unauthorized
    raise GithubSolutionSyncerCreationError, error_message(:authorization_failed)
  rescue Octokit::Error, RestClient::Exception => e
    raise GithubSolutionSyncerCreationError, error_message(:api_error, message: e.message)
  end

  private
  # The installation must be on the personal GitHub account that is
  # linked to this Exercism account. We compare GitHub's numeric account
  # id (stored as the user's uid when they connect GitHub), as it stays
  # the same if the user renames their GitHub account.
  def verify_installation_account!
    raise GithubSolutionSyncerCreationError, error_message(:github_account_not_connected) unless github_uid.present?

    account = installation["account"] || {}

    raise GithubSolutionSyncerCreationError, error_message(:organization_account) if account["type"] != "User"

    return if account["id"].to_s == github_uid

    raise GithubSolutionSyncerCreationError, error_message(:different_github_account)
  end

  def github_uid
    return nil unless user.provider == "github"

    user.uid.to_s
  end

  def error_message(key, **) = I18n.t("#{I18N_SCOPE}.#{key}", **)

  memoize
  def installation = User::GithubSolutionSyncer::GithubApp.fetch_installation!(installation_id)

  memoize
  def client = Octokit::Client.new(access_token: token)

  memoize
  def repo
    repos = client.list_app_installation_repositories.repositories
    raise GithubSolutionSyncerCreationError, error_message(:not_exactly_one_repository) unless repos.size == 1

    repos.first
  end

  memoize
  def token
    User::GithubSolutionSyncer::GithubApp.generate_installation_token!(installation_id).tap do |token|
      raise GithubSolutionSyncerCreationError, error_message(:installation_token_missing) if token.blank?
    end
  end
end
