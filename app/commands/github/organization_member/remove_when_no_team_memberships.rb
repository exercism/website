module Github
  class OrganizationMember
    class RemoveWhenNoTeamMemberships
      include Mandate

      initialize_with :github_username

      def call
        return if organization.team_membership_count_for_user(github_username) >= 1

        organization.remove_member(github_username)
      end

      private
      def organization
        Github::Organization.instance
      end
    end
  end
end
