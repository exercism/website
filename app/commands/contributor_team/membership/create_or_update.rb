class ContributorTeam::Membership
  class CreateOrUpdate
    include Mandate

    initialize_with :user, :team, :attributes

    def call
      membership = ContributorTeam::Membership.create_or_find_by!(user: user, team: team) do |m|
        m.attributes = attributes
      end

      membership.update!(attributes)
      user.update(roles: user.roles + [role]) unless user.roles.include?(role)

      membership
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
