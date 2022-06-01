class ContributorTeam::Membership
  class CreateOrUpdate
    include Mandate

    initialize_with :user, :team, :attributes

    def call
      ContributorTeam::Membership.create!(user:, team:, **attributes).tap do
        user.update(roles: user.roles + [team.role_for_members]) unless user.roles.include?(team.role_for_members)

        team.github_team.add_membership(user.github_username)
      end
    rescue ActiveRecord::RecordNotUnique
      ContributorTeam::Membership.find_by!(user:, team:).tap do |membership|
        membership.update!(attributes)
      end
    end
  end
end
