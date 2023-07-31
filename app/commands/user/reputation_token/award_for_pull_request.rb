class User::ReputationToken::AwardForPullRequest
  include Mandate

  queue_as :reputation

  initialize_with params: Mandate::KWARGS

  def call
    User::ReputationToken::AwardForPullRequestAuthor.(**params)
    User::ReputationToken::AwardForPullRequestReviewers.(**params)
    User::ReputationToken::AwardForPullRequestMerger.(**params)
  end
end
