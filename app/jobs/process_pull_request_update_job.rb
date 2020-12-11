class ProcessPullRequestUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, author, url, html_url)
    User::ReputationToken::AwardForPullRequest.(action, author, url, html_url)
  end
end
