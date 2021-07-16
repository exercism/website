# The goal of this job is to re-sync the team permissions tracks to guard
# against one of the GitHub webhook calls failing, which would result in
# repo permissions not being set correctly
class SyncTeamPermissionsJob < ApplicationJob
  queue_as :dribble

  def perform
    ContributorTeam.find_each do |team|
      ContributorTeam::UpdateReviewersTeamPermissions.(team)
    rescue StandardError => e
      Rails.logger.error "Error updating reviewers team permissions for team #{team.github_name}: #{e}"
    end
  end
end
