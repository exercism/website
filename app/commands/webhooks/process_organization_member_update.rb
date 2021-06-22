module Webhooks
  class ProcessOrganizationMemberUpdate
    include Mandate

    initialize_with :action, :user_name, :organization_name

    def call
      # TODO: use organization as defined in Exercism.config.github_organization
      return unless organization_name == 'exercism'

      case action
      when 'member_added'
        add_member!
      when 'member_removed'
        remove_member!
      end
    end

    private
    def add_member!
      ::Github::OrganizationMember.create!(username: user_name)
    end

    def remove_member!
      ::Github::OrganizationMember.where(username: user_name).update_all(alumnus: true)
    end
  end
end
