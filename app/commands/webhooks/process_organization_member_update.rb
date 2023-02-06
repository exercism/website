class Webhooks::ProcessOrganizationMemberUpdate
  include Mandate

  initialize_with :action, :user_name, :organization_name

  def call
    return unless organization_name == organization.name

    case action
    when 'member_added'
      add_member!
    when 'member_removed'
      remove_member!
    end
  end

  private
  def add_member!
    ::Github::OrganizationMember::CreateOrUpdate.(user_name, alumnus: false)
  end

  def remove_member!
    ::Github::OrganizationMember.where(username: user_name).update_all(alumnus: true)
  end

  def organization
    Github::Organization.instance
  end
end
