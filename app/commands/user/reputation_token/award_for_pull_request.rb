class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      queue_as :reputation

      initialize_with :params

      def call
        User::ReputationToken::AwardForPullRequestAuthor.(params)
        User::ReputationToken::AwardForPullRequestReviewers.(params)
        User::ReputationToken::AwardForPullRequestMerger.(params)
      end
    end
  end
end
