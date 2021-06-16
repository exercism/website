class ContributorTeam::Membership
  class Destroy
    include Mandate

    initialize_with :user, :team

    def call
      ContributorTeam::Membership.where(user: user, team: team).destroy_all
    end
  end
end
