class Github::TeamMember::SyncMembers
  include Mandate

  def call
    delete_team_members!
    add_team_members!
  end

  private
  def add_team_members!
    org_team_members.each do |team_name, user_ids|
      user_ids.each do |user_id|
        ::Github::TeamMember::Create.(user_id, team_name)
      end
    end
  end

  def delete_team_members!
    Github::TeamMember.find_each do |team_member|
      existing_members = org_team_members[team_member.team_name]
      next if existing_members.present? && existing_members.include?(team_member.user_id)

      Github::TeamMember::Destroy.(team_member.user_id, team_member.team_name)
    end
  end

  memoize
  def org_team_members = Github::Organization.instance.team_members
end
