class ProcessPullRequestUpdateJob < ApplicationJob
  extend Mandate::Memoize

  queue_as :default

  def perform(action, github_username, params)
    pr_data = data(action, github_username, params)

    Git::PullRequest::CreateOrUpdate.(
      pr_data[:pr_id],
      pr_number: pr_data[:pr_number],
      author: pr_data[:author],
      repo: pr_data[:repo],
      reviews: pr_data[:reviews],
      data: pr_data
    )

    User::ReputationToken::AwardForPullRequest.(action, github_username, pr_data)
  end

  private
  def data(action, github_username, params)
    {
      action: action,
      author: github_username,
      url: params[:url],
      html_url: params[:html_url],
      labels: params[:labels],
      state: params[:state],
      pr_id: params[:pr_id],
      pr_number: params[:pr_number],
      repo: params[:repo],
      merged: params[:merged],
      merged_by: params[:merged_by],
      # Fetch and add the pull request's reviews as they are not returned in the pull request event
      reviews: reviews(params[:repo], params[:pr_number])
    }
  end

  def reviews(repo, number)
    octokit_client.pull_request_reviews(repo, number).map do |r|
      {
        node_id: r[:node_id],
        reviewer: r[:user][:login]
      }
    end
  end

  memoize
  def octokit_client
    Octokit::Client.new(access_token: Exercism.secrets.github_access_token)
  end
end
