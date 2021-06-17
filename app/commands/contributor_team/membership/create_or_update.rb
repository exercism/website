class ContributorTeam::Membership
  class CreateOrUpdate
    include Mandate

    initialize_with :user, :team, :attributes

    def call
      ContributorTeam::Membership.create!(user: user, team: team, **attributes).tap do
        Github::Team.new(team.github_name).add_member(user.github_username)
      end
    rescue ActiveRecord::RecordNotUnique
      ContributorTeam::Membership.find_by!(user: user, team: team).tap do |membership|
        membership.update!(attributes)
      end
    end
  end
end
