module Webhooks
  class ProcessMembershipUpdate
    include Mandate

    initialize_with :action, :username, :organization

    def call
      return unless organization == 'exercism'

      case action
      when 'member_added'
        add_member!
      when 'member_removed'
        remove_member!
      end
    end

    private
    def add_member!
      ::Github::OrganizationMember.create(username: username)
    end

    def remove_member!
      ::Github::OrganizationMember.destroy_by(username: username)
    end
  end
end
