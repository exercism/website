class Github::TeamMember::Destroy
  include Mandate

  initialize_with :team_member

  def call
    team_member.delete
    User::UpdateMaintainer.(team_member.user) if team_member.track_id
  end
end
