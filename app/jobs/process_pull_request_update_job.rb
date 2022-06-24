class ProcessPullRequestUpdateJob < ApplicationJob
  queue_as :default

  def self.perform_later(pr_data)
    return unless self.worth_queuing?(pr_data)

    super(pr_data)
  end

  def self.worth_queuing?(pr_data) = self.closed?(pr_data) && self.valid_action?(pr_data)
  def self.closed?(pr_data) = pr_data[:state] == 'closed'
  def self.valid_action?(pr_data) = %w[closed labeled unlabeled].include?(pr_data[:action])

  def perform(pr_data)
    # Fetch and append the reviews which the pull request data does not contain
    pr_data[:reviews] = reviews(pr_data[:repo], pr_data[:number])

    Github::PullRequest::CreateOrUpdate.(
      pr_data[:node_id],
      number: pr_data[:number],
      title: pr_data[:title],
      author_username: pr_data[:author_username],
      merged_by_username: pr_data[:merged_by_username],
      repo: pr_data[:repo],
      reviews: pr_data[:reviews],
      data: pr_data
    )

    User::ReputationToken::AwardForPullRequest.(pr_data)
  end

  private
  def reviews(repo, number)
    Exercism.octokit_client.pull_request_reviews(repo, number).map do |r|
      {
        node_id: r[:node_id],
        reviewer_username: r[:user][:login],
        submitted_at: r[:submitted_at]
      }
    end
  end
end
