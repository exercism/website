class Github::TeamMember::Create
  include Mandate

  initialize_with :user, :team_name

  def call
    user.github_team_memberships.find_or_create_by!(team_name:).tap do |team_member|
      next unless team_member.previously_new_record? && team_member.track_id

      User::UpdateMaintainer.(user)
      Track::UpdateGithubMaintenanceStatus.defer(team_member.track)
    end
  end
end
