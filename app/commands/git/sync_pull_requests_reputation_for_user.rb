module Git
  class SyncPullRequestsReputationForUser
    include Mandate

    initialize_with :user

    def call
      return if user.github_username.empty?

      pull_requests.find_each do |pr|
        User::ReputationToken::AwardForPullRequest.(pr.data[:action], pr.data[:author], pr.data)
      rescue StandardError => e
        Rails.logger.error "Error syncing pull request reputation for user #{user.handle}: #{e}"
      end
    end

    private
    def pull_requests
      authored_pull_requests.or(reviewed_pull_requests)
    end

    def authored_pull_requests
      ::Git::PullRequest.joins(:reviews).where(author_github_username: user.handle)
    end

    def reviewed_pull_requests
      ::Git::PullRequest.joins(:reviews).where(reviews: { reviewer_github_username: user.handle })
    end
  end
end
