module Webhooks
  class ProcessMembershipUpdate
    include Mandate

    initialize_with :action, :user_name, :team_name, :organization_name

    def call
      # TODO: use organization as defined in Exercism.config.github_organization
      return unless organization_name == 'exercism'

      case action
      when 'added'
        add_membership!
      when 'removed'
        remove_membership!
      end
    end

    private
    def add_membership!
      ContributorTeam::Membership::CreateOrUpdate.(user, team, status: :active)
    end

    def remove_membership!
      ContributorTeam::Membership::Destroy.(user, team)
    end

    def user
      User.find_by!(github_username: user_name)
    end

    def team
      ContributorTeam.find_by!(github_name: team_name)
    end
  end
end
