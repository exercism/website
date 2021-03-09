class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        User::ReputationToken::AwardForPullRequestAuthor.(action, github_username, params)
        User::ReputationToken::AwardForPullRequestReviewers.(action, github_username, params)
      end
    end
  end
end
