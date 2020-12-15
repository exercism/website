class ProcessPullRequestUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, github_username, url, html_url)
    User::ReputationToken::AwardForPullRequest.(action, github_username, url, html_url)
  end
end
