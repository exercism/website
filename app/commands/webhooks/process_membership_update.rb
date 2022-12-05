module Webhooks
  class ProcessMembershipUpdate
    include Mandate

    initialize_with :action, :user_name, :team_name, :organization_name

    def call
      return unless %(added removed).include?(action)
      return unless organization_name == organization.name
    end

    private
    memoize
    def user = User.find_by(github_username: user_name)

    memoize
    def organization = Github::Organization.instance
  end
end
