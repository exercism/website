class ProcessPullRequestUpdateJob < ApplicationJob
  queue_as :default

  def self.perform_later(pull_request_update)
    return unless self.worth_queuing?(pull_request_update)

    super(pull_request_update)
  end

  def self.worth_queuing?(pull_request_update) = self.closed?(pull_request_update) && self.valid_action?(pull_request_update)
  def self.closed?(pull_request_update) = pull_request_update[:state] == 'closed'
  def self.valid_action?(pull_request_update) = %w[closed labeled unlabeled].include?(pull_request_update[:action])

  def perform(pull_request_update)
    # Fetch and append the reviews which the pull request data does not contain
    pull_request_update[:reviews] = reviews(pull_request_update[:repo], pull_request_update[:number])

    Github::PullRequest::CreateOrUpdate.(
      pull_request_update[:node_id],
      number: pull_request_update[:number],
      title: pull_request_update[:title],
      author_username: pull_request_update[:author_username],
      merged_by_username: pull_request_update[:merged_by_username],
      repo: pull_request_update[:repo],
      reviews: pull_request_update[:reviews],
      data: pull_request_update
    )

    User::ReputationToken::AwardForPullRequest.(pull_request_update)
  end

  private
  def reviews(repo, number)
    Exercism.octokit_client.pull_request_reviews(repo, number).map do |review|
      {
        node_id: review[:node_id],
        reviewer_username: review[:user][:login],
        submitted_at: r[:submitted_at]
      }
    end
  end
end
