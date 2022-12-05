class Github::TeamMember::SyncMembers
  include Mandate

  def call
    team_members = add_team_members!
    delete_team_members!(team_members)
  end

  private
  def add_team_members!
    org_team_members.flat_map do |team_name, user_ids|
      user_ids.map { |user_id| ::Github::TeamMember::Create.(user_id, team_name) }
    end
  end

  def delete_team_members!(current_team_members)
    Github::TeamMember.where.not(id: current_team_members.map(&:id)).destroy_all
  end

  memoize
  def org_team_members = Github::Organization.instance.team_members
end
