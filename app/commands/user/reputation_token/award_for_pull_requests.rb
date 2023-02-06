class User::ReputationToken::AwardForPullRequests
  include Mandate

  def call
    pull_requests.find_each do |pr|
      User::ReputationToken::AwardForPullRequest.defer(**pr.data)
    rescue StandardError => e
      Rails.logger.error "Error syncing pull request reputation for #{pr.repo}/#{pr.number}: #{e}"
    end
  end

  private
  def pull_requests
    ::Github::PullRequest.not_open.left_joins(:reviews)
  end
end
