class Github::Team
  include Mandate

  initialize_with :name

  def create(repo)
    Exercism.octokit_client.create_team(organization, name: name, repo_names: [repo])
  end

  def add_member(github_username)
    Exercism.octokit_client.add_team_membership(team_id, github_username)
  end

  def remove_member(github_username)
    Exercism.octokit_client.remove_team_membership(team_id, github_username)
  end

  def add_to_repository(repo, permission)
    Exercism.octokit_client.add_team_repository(team_id, repo, permission: permission)
  end

  def remove_from_repository(repo)
    Exercism.octokit_client.remove_team_repository(team_id, repo)
  end

  memoize
  def members
    Exercism.octokit_client.team_members(team_id)
  end

  memoize
  def team_id
    # The octokit client does not surface the API method to retrieve a team
    # by its github team name, so we just call it directly
    Exercism.octokit_client.get("https://api.github.com/orgs/#{organization}/teams/#{name}")[:id]
  end

  def organization
    # TODO: set this variable depending on the environment
    Exercism.config.github_organization
  end
end
