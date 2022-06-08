class ContributorTeam::Membership
  class Destroy
    include Mandate

    initialize_with :user, :team

    def call
      ContributorTeam::Membership.where(user:, team:).destroy_all

      user.update(roles: user.roles - [team.role_for_members]) unless remains_in_team_role?

      team.github_team.remove_membership(user.github_username)
    end

    private
    memoize
    def remains_in_team_role?
      user.teams.map(&:role_for_members).include?(team.role_for_members)
    end
  end
end
