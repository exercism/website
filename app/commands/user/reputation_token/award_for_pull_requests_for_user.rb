class User::ReputationToken::AwardForPullRequestsForUser
  include Mandate

  queue_as :reputation

  initialize_with :user

  def call
    return if user.github_username.blank?

    pull_requests.find_each do |pr|
      User::ReputationToken::AwardForPullRequest.(**pr.data)
    rescue StandardError => e
      Rails.logger.error "Error syncing pull request reputation for user #{user.handle} and pr #{pr.repo}/#{pr.number}: #{e}"
    end
  end

  private
  def pull_requests
    [authored_pull_requests, merged_pull_requests, reviewed_pull_requests].flatten.uniq
  end

  def authored_pull_requests
    ::Github::PullRequest.not_open.where(author_username: user.github_username)
  end

  def merged_pull_requests
    ::Github::PullRequest.not_open.where(merged_by_username: user.github_username)
  end

  def reviewed_pull_requests
    ::Github::PullRequest.not_open.left_joins(:reviews).where(reviews: { reviewer_username: user.github_username })
  end
end
