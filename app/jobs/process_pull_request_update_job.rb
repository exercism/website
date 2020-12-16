class ProcessPullRequestUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, github_username, params)
    User::ReputationToken::AwardForPullRequest.(action, github_username, params)
  end
end
