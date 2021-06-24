class ContributorTeam::Membership
  class AddProjectMaintainer
    include Mandate

    initialize_with :user, :name, :attributes

    def call
      team = ContributorTeam.find_by!(name: name, type: :project_maintainers)
      ContributorTeam::Membership::CreateOrUpdate.(user, team, attributes)

      user.update(roles: user.roles + [:maintainer]) unless user.roles.include?(:maintainer)
    end
  end
end
