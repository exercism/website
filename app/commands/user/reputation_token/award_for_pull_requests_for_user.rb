class User::ReputationToken::AwardForPullRequestsForUser
  include Mandate

  queue_as :reputation

  initialize_with :user

  def call
    return if user.github_username.blank?

    Github::PullRequest.where(id: pull_request_ids).find_each do |pr|
      User::ReputationToken::AwardForPullRequest.(**pr.data)
    rescue StandardError => e
      Rails.logger.error "Error syncing pull request reputation for user #{user.handle} and pr #{pr.repo}/#{pr.number}: #{e}"
    end
  end

  private
  def pull_request_ids
    [authored_pull_request_ids, merged_pull_request_ids, reviewed_pull_request_ids].flatten.uniq
  end

  def authored_pull_request_ids
    ::Github::PullRequest.not_open.where(author_username: user.github_username).pluck(:id)
  end

  def merged_pull_request_ids
    ::Github::PullRequest.not_open.where(merged_by_username: user.github_username).pluck(:id)
  end

  def reviewed_pull_request_ids
    ::Github::PullRequest.not_open.left_joins(:reviews).where(reviews: { reviewer_username: user.github_username }).pluck(:id)
  end
end
