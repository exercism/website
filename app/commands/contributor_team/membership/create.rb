class ContributorTeam::Membership
  class Create
    include Mandate

    initialize_with :user, :team, :attributes

    def call
      ContributorTeam::Membership.create_or_find_by!(
        user: user,
        team: team,
        **attributes
      )
    end
  end
end
