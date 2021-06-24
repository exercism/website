class ContributorTeam
  class CheckOrgMembership
    include Mandate

    initialize_with :user

    def call
      return if organization.team_memberships_count(user) >= 1

      Exercism.octokit_client.remove_organization_membership(organization.name, user.github_username)
    end

    private
    memoize
    def organization
      Github::Organization.new
    end
  end
end
