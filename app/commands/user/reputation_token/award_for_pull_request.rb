class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        # TODO: update pull request

        User::ReputationToken::AwardForPullRequestAuthor.(action, github_username, params)
        User::ReputationToken::AwardForPullRequestReviewers.(action, github_username, params)
      end
    end
  end
end
