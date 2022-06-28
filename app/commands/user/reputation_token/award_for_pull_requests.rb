class User
  class ReputationToken
    class AwardForPullRequests
      include Mandate

      def call
        pull_requests.find_each do |pr|
          AwardReputationForPullRequestJob.perform_later(pr.data)
        rescue StandardError => e
          Rails.logger.error "Error syncing pull request reputation for #{pr.repo}/#{pr.number}: #{e}"
        end
      end

      private
      def pull_requests
        ::Github::PullRequest.not_open.left_joins(:reviews)
      end
    end
  end
end
