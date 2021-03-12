class ProcessPullRequestUpdateJob < ApplicationJob
  extend Mandate::Memoize

  queue_as :default

  def perform(pr_data)
    # Fetch and append the reviews which the pull request data does not contain
    pr_data[:reviews] = reviews(pr_data[:repo], pr_data[:number])

    Github::PullRequest::CreateOrUpdate.(
      pr_data[:node_id],
      number: pr_data[:number],
      author_username: pr_data[:author_username],
      repo: pr_data[:repo],
      reviews: pr_data[:reviews],
      data: pr_data
    )

    User::ReputationToken::AwardForPullRequest.(pr_data)
  end

  private
  def reviews(repo, number)
    octokit_client.pull_request_reviews(repo, number).map do |r|
      {
        node_id: r[:node_id],
        reviewer_username: r[:user][:login],
        submitted_at: r[:submitted_at].present? ? r[:submitted_at].iso8601 : nil
      }
    end
  end

  memoize
  def octokit_client
    Octokit::Client.new(access_token: Exercism.secrets.github_access_token).tap do |c|
      c.auto_paginate = true
    end
  end
end
