class AwardPullRequestReputationJob < ApplicationJob
  queue_as :reputation

  def perform(user)
    Git::SyncPullRequestsReputationForUser.(user)
  end
end
