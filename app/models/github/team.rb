class Github::Team
  include Mandate

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def add_membership(github_username)
    return unless organization.active?

    Exercism.octokit_client.add_team_membership(team_id, github_username)
  end

  def remove_membership(github_username)
    return unless organization.active?

    Exercism.octokit_client.remove_team_membership(team_id, github_username)
  end

  def add_to_repository(repo_name, permission)
    return unless organization.active?

    Exercism.octokit_client.add_team_repository(team_id, repo_name, permission:)
  end

  def remove_from_repository(repo_name)
    return unless organization.active?

    Exercism.octokit_client.remove_team_repository(team_id, repo_name)
  end

  def repositories
    return unless organization.active?

    Exercism.octokit_client.team_repositories(team_id)
  end

  def members
    return unless organization.active?

    Exercism.octokit_client.team_members(team_id)
  end

  def create(repo_name, parent_team: nil)
    return unless organization.active?

    Exercism.octokit_client.create_team(organization.name,
      name:,
      repo_names: ["#{organization.name}/#{repo_name}"],
      privacy: :closed,
      parent_team_id: parent_team&.team_id,
      accept: 'application/vnd.github.hellcat-preview+json')
  end

  memoize
  def team_id
    Exercism.octokit_client.team_by_name(organization.name, name).id
  end

  def organization
    Github::Organization.instance
  end
end
