class ContributorTeam
  class AddTrackMaintainer
    include Mandate

    initialize_with :user, :track, :attributes

    def call
      @team = ContributorTeam.find_by!(track: track, type: :track_maintainers)
      ContributorTeam::Membership::CreateOrUpdate.(user, team, attributes)

      if well_maintained?
        github_reviewers_team.remove_from_repository(track.repo_name)
      else
        github_reviewers_team.add_to_repository(track.repo_name, :push)
      end

      user.update(roles: user.roles + [:maintainer]) unless user.roles.include?(:maintainer)
    end

    private
    attr_reader :team

    def well_maintained?
      Github::Team.new(team.github_name).members.size >= 2
    end

    def github_reviewers_team
      Github::Team.new('reviewers')
    end
  end
end
