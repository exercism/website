# The goal of this job is to re-calculate the reputation that is awarded
# for actions related to pull requests (creating, reviewing and merging)
# to guard against one of the GitHub webhook calls failing, which would
# result in reputation not being awarded
class FetchAndSyncAllPullRequestsReputationJob < ApplicationJob
  queue_as :dribble

  def perform
    Github::PullRequest::SyncRepos.()
    Github::OrganizationMember::SyncMembers.()
    User::ReputationToken::AwardForPullRequests.()
  end
end
