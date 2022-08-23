class ProcessPullRequestUpdateJob < ApplicationJob
  queue_as :default

  def self.perform_later(pull_request_update)
    return unless self.worth_queuing?(pull_request_update)

    super(pull_request_update)
  end

  def self.worth_queuing?(pull_request_update)
    %w[closed edited opened reopened labeled unlabeled].include?(pull_request_update[:action])
  end

  def perform(pull_request_update)
    # Add the reviews to the pull request update as it does not have
    # that information by default
    add_reviews!(pull_request_update)

    Github::PullRequest::CreateOrUpdate.(
      pull_request_update[:node_id],
      number: pull_request_update[:number],
      title: pull_request_update[:title],
      author_username: pull_request_update[:author_username],
      merged_by_username: pull_request_update[:merged_by_username],
      repo: pull_request_update[:repo],
      reviews: pull_request_update[:reviews],
      state: state(pull_request_update),
      data: pull_request_update
    )

    User::ReputationToken::AwardForPullRequest.(**pull_request_update) if award_reputation_tokens?(pull_request_update)
  end

  private
  def add_reviews!(pull_request_update)
    pull_request_update[:reviews] = reviews(pull_request_update[:repo], pull_request_update[:number])
  end

  def award_reputation_tokens?(pull_request_update)
    %w[closed labeled unlabeled].include?(pull_request_update[:action])
  end

  def state(pull_request_update)
    return :merged if !!pull_request_update[:merged]

    pull_request_update[:state].downcase.to_sym
  end

  def reviews(repo, number)
    Exercism.octokit_client.pull_request_reviews(repo, number).map do |review|
      {
        node_id: review[:node_id],
        reviewer_username: review[:user][:login],
        submitted_at: review[:submitted_at]
      }
    end
  end
end
