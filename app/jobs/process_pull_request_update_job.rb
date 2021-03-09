class ProcessPullRequestUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, github_username, params)
    # Fetch the reviews, as GitHub pull request events don't contain them
    params[:reviews] = reviews

    User::ReputationToken::AwardForPullRequest.(action, github_username, params)
  end

  private
  def reviews
    octokit_client.pull_request_reviews(repo, pr_number)
  end

  memoize
  def octokit_client
    Octokit::Client.new(access_token: Exercism.secrets.github_access_token)
  end
end
