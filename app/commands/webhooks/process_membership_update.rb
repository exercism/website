module Webhooks
  class ProcessMembershipUpdate
    include Mandate

    initialize_with :action, :user_name, :team_name, :organization_name

    def call
      # TODO: use organization as defined in Exercism.config.github_organization
      return unless organization_name == 'exercism'
      return unless action == 'added' || action == 'removed'
      return unless team
      return unless user

      # If the action was 'removed', that means the membership was removed on GitHub.
      # However, as the data in our database is leading, we'll re-add the membership
      ContributorTeam::Membership::CreateOrUpdate.(user, team, status: :active)
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
