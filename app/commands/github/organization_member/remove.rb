module Github
  class OrganizationMember
    class Remove
      include Mandate

      initialize_with :github_username

      def call
        Exercism.octokit_client.remove_organization_member('exercism', github_username)
      end
    end
  end
end
