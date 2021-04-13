class User
  class ReputationToken
    class AwardForPullRequestsForUser
      include Mandate

      initialize_with :user

      def call
        return if user.github_username.blank?

        pull_requests.find_each do |pr|
          User::ReputationToken::AwardForPullRequest.(pr.data)
        rescue StandardError => e
          Rails.logger.error "Error syncing pull request reputation for user #{user.handle} and pr #{pr.repo}/#{pr.number}: #{e}" # rubocop:disable Layout/LineLength
        end
      end

      private
      def pull_requests
        authored_pull_requests.or(merged_pull_requests).or(reviewed_pull_requests)
      end

      def authored_pull_requests
        ::Github::PullRequest.left_joins(:reviews).where(author_username: user.github_username)
      end

      def merged_pull_requests
        ::Github::PullRequest.left_joins(:reviews).where(merged_by_username: user.github_username)
      end

      def reviewed_pull_requests
        ::Github::PullRequest.left_joins(:reviews).where(reviews: { reviewer_username: user.github_username })
      end
    end
  end
end
