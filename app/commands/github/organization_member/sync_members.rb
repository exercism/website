class Github::OrganizationMember::SyncMembers
  include Mandate

  def call
    organization_member_usernames.each do |username|
      ::Github::OrganizationMember::CreateOrUpdate.(username, alumnus: false)
    end

    ::Github::OrganizationMember.where.not(username: organization_member_usernames).update_all(alumnus: true)

    ::Github::OrganizationMember.where.not(username: organization.team_member_usernames).find_each do |member|
      organization.remove_member(member.username)
    end
  end

  private
  memoize
  def organization_member_usernames
    organization.member_usernames
  end

  def organization
    Github::Organization.instance
  end
end
