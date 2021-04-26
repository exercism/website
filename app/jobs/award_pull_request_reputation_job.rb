class AwardPullRequestReputationJob < ApplicationJob
  queue_as :low_priority

  def perform(user)
    User::ReputationToken::AwardForPullRequestsForUser.(user)
  end
end
