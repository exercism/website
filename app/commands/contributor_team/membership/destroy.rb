class ContributorTeam::Membership
  class Destroy
    include Mandate

    initialize_with :user, :team

    def call
      ContributorTeam::Membership.where(user: user, team: team).destroy_all

      user.update(roles: user.roles - [role])
    end

    private
    memoize
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
