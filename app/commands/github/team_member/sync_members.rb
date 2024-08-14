class Github::TeamMember::SyncMembers
  include Mandate

  def call
    delete_team_members!
    add_team_members!
  end

  private
  def add_team_members!
    org_team_members.each do |team_name, github_uids|
      github_uids.each do |github_uid|
        ::Github::TeamMember::Create.(github_uid, team_name)
      end
    end
  end

  def delete_team_members!
    Github::TeamMember.includes(:user).find_each do |team_member|
      next if org_team_members[team_member.team_name].to_a.include?(team_member.user.uid)

      Github::TeamMember::Destroy.(team_member.user.uid, team_member.team_name)
    end
  end

  memoize
  def org_team_members = Github::Organization.instance.team_members
end
