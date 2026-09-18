class Github::TeamMember::Destroy
  include Mandate

  initialize_with :team_member

  def call
    team_member.delete
    return unless team_member.track_id

    User::UpdateMaintainer.(team_member.user)
    Track::UpdateGithubMaintenanceStatus.defer(team_member.track)
  end
end
