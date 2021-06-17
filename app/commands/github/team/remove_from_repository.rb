module Github::Team
  class RemoveFromRepository
    include Mandate

    initialize_with :github_team_name, :repo

    def call
      Exercism.octokit_client.remove_team_repository(team_id, repo)
    end

    def team_id
      # The octokit client does not surface the API method to retrieve a team
      # by its github team name, so we just call it directly
      Exercism.octokit_client.get("https://api.github.com/orgs/exercism/teams/#{github_team_name}")[:id]
    end
  end
end
