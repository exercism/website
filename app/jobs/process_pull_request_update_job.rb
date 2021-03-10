class ProcessPullRequestUpdateJob < ApplicationJob
  include Mandate

  queue_as :default

  def perform(action, github_username, params)
    # Fetch and add the pull request's reviews as they are not returned in the pull request event
    params[:reviews] = reviews(params[:repo], params[:number])

    User::ReputationToken::AwardForPullRequest.(action, github_username, params)
  end

  private
  def reviews(repo, number)
    octokit_client.pull_request_reviews(repo, number)
  end

  memoize
  def octokit_client
    Octokit::Client.new(access_token: Exercism.secrets.github_access_token)
  end
end
