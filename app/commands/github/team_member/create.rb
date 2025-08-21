class Github::TeamMember::Create
  include Mandate

  initialize_with :user, :team_name

  def call
    user.github_team_memberships.find_or_create_by!(team_name:).tap do |team_member|
      User::UpdateMaintainer.(user) if team_member.previously_new_record? && team_member.track_id
    end
  end
end
