class Github::Repository::UpdateMaintainersAdminTeamPermissions
  include Mandate

  initialize_with :repos

  def call
    repos.each do |repo|
      Exercism.octokit_client.add_team_repository(maintainers_admin_team.id, repo.name_with_owner, permission: :maintain)
    end
  end

  private
  memoize
  def maintainers_admin_team
    Exercism.octokit_client.team_by_name("exercism", "maintainers-admin")
  end
end
