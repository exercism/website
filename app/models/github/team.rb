class Github::Team
  include Mandate

  initialize_with :name

  def create(repo_name, parent_team: nil)
    return unless active?

    Exercism.octokit_client.create_team(organization,
      name: name,
      repo_names: ["#{organization}/#{repo_name}"],
      privacy: :closed,
      parent_team_id: parent_team&.team_id,
      accept: 'application/vnd.github.hellcat-preview+json')
  end

  def add_member(github_username)
    return unless active?

    Exercism.octokit_client.add_team_membership(team_id, github_username)
  end

  def remove_member(github_username)
    return unless active?

    Exercism.octokit_client.remove_team_membership(team_id, github_username)
  end

  def add_to_repository(repo_name, permission)
    return unless active?

    Exercism.octokit_client.add_team_repository(team_id, "#{organization}/#{repo_name}", permission: permission)
  end

  def remove_from_repository(repo_name)
    return unless active?

    Exercism.octokit_client.remove_team_repository(team_id, "#{organization}/#{repo_name}")
  end

  memoize
  def members
    return unless active?

    Exercism.octokit_client.team_members(team_id)
  end

  memoize
  def team_id
    # The octokit client does not surface the API method to retrieve a team
    # by its github team name, so we just call it directly
    Exercism.octokit_client.get("https://api.github.com/orgs/#{organization}/teams/#{name}")[:id]
  end

  memoize
  def active?
    organization.present?
  end

  memoize
  def organization
    return ENV["GITHUB_ORGANIZATION"] || Exercism.config.github_organization if Rails.env.development?

    # TODO: add github_organization property to Exercism.config
    Exercism.config.github_organization
  end
end
