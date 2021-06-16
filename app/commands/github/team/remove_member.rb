module Github::Team
  class RemoveMember
    include Mandate

    initialize_with :github_team_name, :github_username

    def call
      Exercism.octokit_client.remove_team_membership(team_id, github_username)
    end

    def team_id
      # The octokit client does not surface the API method to retrieve a team
      # by its github team name, so we just call it directly
      Exercism.octokit_client.get("https://api.github.com/orgs/exercism/teams/#{github_team_name}")[:id]
    end
  end
end
