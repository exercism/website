class AwardReputationToUserForPullRequestsJob < ApplicationJob
  queue_as :reputation

  def perform(user)
    User::ReputationToken::AwardForPullRequestsForUser.(user)
  end
end
