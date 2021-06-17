class ContributorTeam
  class AddTrackMaintainer
    include Mandate

    initialize_with :user, :track, :attributes

    def call
      team = ContributorTeam.find_by!(track: track, type: :track_maintainers)
      ContributorTeam::Membership::CreateOrUpdate.(user, team, attributes)

      Github::Team::AddMember.(team.github_name, user.github_username)

      if not_well_maintained?
        Github::Team::AddToRepository('reviewers', track.repo)
      else
        Github::Team::RemoveFromRepository('reviewers', track.repo)
      end

      user.update(roles: user.roles + [:maintainer]) unless user.roles.include?(:maintainer)
    end

    private
    def not_well_maintained?
      Github::Team::FetchMembers.(team.github_name).size < 2
    end
  end
end
