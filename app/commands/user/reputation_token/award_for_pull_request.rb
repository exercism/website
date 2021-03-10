class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        # TODO: update pull request
        # TODO: award pull request merger

        User::ReputationToken::AwardForPullRequestAuthor.(action, github_username, params)
        User::ReputationToken::AwardForPullRequestReviewers.(action, github_username, params) if has_reviews?
      end

      private
      def has_reviews?
        params[:reviews].present?
      end
    end
  end
end
