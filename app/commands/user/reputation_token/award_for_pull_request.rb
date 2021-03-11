class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        User::ReputationToken::AwardForPullRequestAuthor.(action, github_username, params) if params[:author].present?
        User::ReputationToken::AwardForPullRequestReviewers.(action, github_username, params) if params[:reviews].present?
        User::ReputationToken::AwardForPullRequestMerger.(action, github_username, params) if params[:merged].present?
      end
    end
  end
end
