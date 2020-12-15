class ProcessPullRequestUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, github_username, url, html_url, labels)
    User::ReputationToken::AwardForPullRequest.(action, github_username, url, html_url, labels)
  end
end
