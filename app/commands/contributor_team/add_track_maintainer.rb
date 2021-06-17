class ContributorTeam
  class AddTrackMaintainer
    include Mandate

    initialize_with :user, :track, :attributes

    def call
      team = ContributorTeam.find_by!(track: track)
      ContributorTeam::Membership::CreateOrUpdate.(user, team, attributes)
    end
  end
end
