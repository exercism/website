class ContributorTeam
  class AddTrackMaintainer
    include Mandate

    initialize_with :user, :track, :attributes

    def call
      team = ContributorTeam.find_by!(track: track, type: :track_maintainers)
      Github::Team::AddMember.(team.github_name, user.github_username)
      ContributorTeam::Membership::CreateOrUpdate.(user, team, attributes)
      user.update(roles: user.roles + [:maintainer]) unless user.roles.include?(:maintainer)

      # TODO: give reviewers write permissions if only zero or one members in track team
    end
  end
end
