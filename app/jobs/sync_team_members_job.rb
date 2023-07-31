# The goal of this job is to re-sync the team members to guard against
# one of the GitHub webhook calls failing, which would result in our
# team members data not being correct
class SyncTeamMembersJob < ApplicationJob
  queue_as :dribble

  def perform = Github::TeamMember::SyncMembers.()
end
