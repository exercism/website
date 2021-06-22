class ContributorTeam::Membership
  class Destroy
    include Mandate

    initialize_with :user, :team

    def call
      ContributorTeam::Membership.where(user: user, team: team).destroy_all

      Github::Team.new(team.github_name).remove_member(user.github_username) unless member_of_at_least_one_team?

      user.update(roles: user.roles - [role]) unless keep_role?
    end

    private
    memoize
    def keep_role?
      user.teams.any? { |t| t.type == team.type }
    end

    def role
      case team.type
      when :track_maintainers
        :maintainer
      when :reviewers
        :reviewer
      end
    end

    def member_of_at_least_one_team?
      query = <<~QUERY.strip
        {
          organization(login: "exercism") {
            teams(userLogins: ["#{user.github_username}"]) {
              totalCount
            }
          }
        }
      QUERY

      response = Exercism.octokit_client.post("https://api.github.com/graphql", { query: query }.to_json).to_h
      response.dig(:data, :organization, :teams, :totalCount) >= 1
    end
  end
end
