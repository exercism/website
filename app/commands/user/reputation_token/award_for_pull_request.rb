class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        User::ReputationToken::AwardForPullRequestAuthor.(action, github_username, params)
        User::ReputationToken::AwardForPullRequestReviewers.(action, github_username, params) if has_reviews?
        User::ReputationToken::AwardForPullRequestMerger.(action, github_username, params) if merged?
      end

      private
      def has_reviews?
        params[:reviews].present?
      end

      def merged?
        params[:merged].present?
      end
    end
  end
end
