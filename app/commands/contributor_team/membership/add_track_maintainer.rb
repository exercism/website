class ContributorTeam::Membership
  class AddTrackMaintainer
    include Mandate

    initialize_with :user, :track, :attributes

    def call
      @team = ContributorTeam.find_by!(track: track, type: :track_maintainers)
      ContributorTeam::Membership::CreateOrUpdate.(user, team, attributes)

      user.update(roles: user.roles + [:maintainer]) unless user.roles.include?(:maintainer)

      if well_maintained?
        github_reviewers_team.remove_from_repository(track.repo_name)
      else
        github_reviewers_team.add_to_repository(track.repo_name, :push)
      end
    end

    private
    attr_reader :team

    def well_maintained?
      team.memberships.where(status: :active).size >= 2
    end

    def github_reviewers_team
      Github::Team.new('reviewers')
    end
  end
end
