module Webhooks
  class ProcessMembershipUpdate
    include Mandate

    initialize_with :action, :user_name, :team_name, :organization_name

    def call
      return unless %(added removed).include?(action)
      return unless organization_name == organization.name

      ContributorTeam::UpdateReviewersTeamPermissions.(team) if team
      Github::OrganizationMember::RemoveWhenNoTeamMemberships.(user.github_username) if user
    end

    private
    memoize
    def user
      User.find_by(github_username: user_name)
    end

    memoize
    def team
      ContributorTeam.find_by(github_name: team_name)
    end

    def organization
      Github::Organization.instance
    end
  end
end
