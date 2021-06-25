class ContributorTeam
  class UpdateReviewersTeamPermissions
    include Mandate

    initialize_with :team

    def call
      if team.memberships.size < 2
        team_repository_names.each do |repo_name|
          reviewers_team.add_to_repository(repo_name, :push)
        end
      else
        team_repository_names.each do |repo_name|
          reviewers_team.remove_from_repository(repo_name)
        end
      end
    end

    private
    memoize
    def reviewers_team
      Github::Team.new('reviewers')
    end

    def team_repository_names
      team.github_team.repositories.pluck(:full_name)
    end
  end
end
