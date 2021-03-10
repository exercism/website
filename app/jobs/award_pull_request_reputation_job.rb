class AwardPullRequestReputationJob < ApplicationJob
  queue_as :reputation

  def perform(user)
    User::ReputationToken::AwardForPullRequests.(user)
  end
end
