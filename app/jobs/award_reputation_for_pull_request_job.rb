class AwardReputationForPullRequestJob < ApplicationJob
  queue_as :reputation

  def perform(params)
    User::ReputationToken::AwardForPullRequest.(params)
  end
end
