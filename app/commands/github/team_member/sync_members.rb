class Github::TeamMember::SyncMembers
  include Mandate

  def call
    add_team_members!
    delete_team_members!
  end

  private
  def add_team_members!
    org_team_members.each do |team_name, github_uids|
      github_uids.each do |github_uid|
        user = team_member_users_by_uid[github_uid]
        ::Github::TeamMember::Create.(user, team_name) if user
      end
    end
  end

  def delete_team_members!
    team_members.each do |team_member|
      next if org_team_members[team_member.team_name].to_a.include?(team_member.user.uid)

      Github::TeamMember::Destroy.(team_member)
    end
  end

  memoize
  def org_team_members = Github::Organization.instance.team_members.transform_values { |uids| uids.map(&:to_s) }

  memoize
  def team_members = Github::TeamMember.includes(:user)

  memoize
  def team_member_users_by_uid = User.where(uid: org_team_members.values.flatten).index_by(&:uid)
end
