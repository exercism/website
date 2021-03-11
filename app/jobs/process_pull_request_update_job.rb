class ProcessPullRequestUpdateJob < ApplicationJob
  extend Mandate::Memoize

  queue_as :default

  def perform(params)
    @params = params

    Github::PullRequest::CreateOrUpdate.(
      data[:pr_node_id],
      pr_number: data[:pr_number],
      author: data[:author],
      repo: data[:repo],
      reviews: data[:reviews],
      data: data
    )

    User::ReputationToken::AwardForPullRequest.(data)
  end

  private
  attr_reader :params

  memoize
  def data
    {
      action: params[:action],
      author: params[:author],
      url: params[:url],
      html_url: params[:html_url],
      labels: params[:labels],
      state: params[:state],
      pr_node_id: params[:pr_node_id],
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
    Octokit::Client.new(access_token: Exercism.secrets.github_access_token).tap do |c|
      c.auto_paginate = true
    end
  end
end
