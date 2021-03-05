module Git
  class SyncPullRequestsReputation
    include Mandate

    def call
      ::Git::PullRequest.find_each do |pr|
        User::ReputationToken::AwardForPullRequest.(pr.data[:action], pr.author, pr.data)
      rescue StandardError => e
        Rails.logger.error "Error syncing pull request reputation for #{pr.repo}/#{pr.number}: #{e}"
      end
    end
  end
end
