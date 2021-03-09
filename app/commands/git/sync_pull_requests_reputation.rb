module Git
  class SyncPullRequestsReputation
    include Mandate

    def call
      unprocessed_pull_requests.find_each do |pr|
        User::ReputationToken::AwardForPullRequest.(pr.data[:action], pr.author_github_username, pr.data)
        pr.update!(processed: true)
      rescue StandardError => e
        Rails.logger.error "Error syncing pull request reputation for #{pr.repo}/#{pr.number}: #{e}"
      end
    end

    private
    def unprocessed_pull_requests
      ::Git::PullRequest.where(processed: false)
    end
  end
end
