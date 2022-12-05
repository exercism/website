module Webhooks
  class ProcessMembershipUpdate
    include Mandate

    initialize_with :action, :user_name, :team_name, :organization_name

    def call
      return unless %(added removed).include?(action)
      return unless organization_name == organization.name

      case action
      when 'added'
        Github::TeamMember::Create.(user_name, team_name)
      when 'removed'
        Github::TeamMember::Destroy.(user_name, team_name)
      end
    end

    private
    memoize
    def organization = Github::Organization.instance
  end
end
