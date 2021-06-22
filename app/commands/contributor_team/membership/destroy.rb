class ContributorTeam::Membership
  class Destroy
    include Mandate

    initialize_with :user, :team

    def call
      ContributorTeam::Membership.where(user: user, team: team).destroy_all

      # TODO: remove member from organization if no team memberships remaining

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
  end
end
