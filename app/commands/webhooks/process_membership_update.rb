module Webhooks
  class ProcessMembershipUpdate
    include Mandate

    initialize_with :action, :user_name, :team_name, :organization_name

    def call
      return unless %(added removed).include?(action)
      return unless team
      return unless user
      return unless organization_name == team.github_team.organization

      ContributorTeam::UpdateReviewersPermission.(team)
      ContributorTeam::CheckOrgMembership.(user)
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
  end
end
