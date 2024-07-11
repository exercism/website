class User::UpdateMaintainer
  include Mandate

  initialize_with :user

  def call
    if member_of_track_team?
      User::AddRoles.(user, [:maintainer])
    else
      User::RemoveRoles.(user, [:maintainer])
    end
  end

  private
  def member_of_track_team?
    user.github_team_memberships.where(team_name: Track.pluck(:slug)).exists?
  end
end
