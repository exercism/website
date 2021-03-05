FactoryBot.define do
  factory :user_code_contribution_reputation_token, class: 'User::ReputationTokens::CodeContributionToken' do
    user
    level { :regular }

    params do
      {
        repo: "exercism/ruby",
        pr_id: SecureRandom.uuid,
        pr_number: SecureRandom.uuid
      }
    end
  end

  factory :user_code_review_reputation_token, class: 'User::ReputationTokens::CodeReviewToken' do
    user

    params do
      {
        repo: "exercism/ruby",
        pr_id: SecureRandom.uuid,
        pr_number: SecureRandom.uuid
      }
    end
  end

  factory :user_exercise_contribution_reputation_token, class: 'User::ReputationTokens::ExerciseContributionToken' do
    user

    params do
      {
        contributorship: create(:exercise_contributorship, contributor: user)
      }
    end
  end

  factory :user_exercise_author_reputation_token, class: 'User::ReputationTokens::ExerciseAuthorToken' do
    user

    params do
      {
        authorship: create(:exercise_authorship, author: user)
      }
    end
  end
end
