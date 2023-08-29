FactoryBot.define do
  factory :user_reputation_token, class: 'User::ReputationTokens::CodeContributionToken' do
    user
    level { :medium }

    params do
      {
        repo: "exercism/ruby",
        pr_node_id: SecureRandom.uuid,
        pr_number: SecureRandom.random_number(100_000),
        pr_title: "The cat sat on the mat",
        earned_on: Time.current - SecureRandom.random_number(100_000).seconds
      }
    end
  end

  factory :user_code_contribution_reputation_token, class: 'User::ReputationTokens::CodeContributionToken' do
    user
    level { :medium }

    params do
      {
        repo: "exercism/ruby",
        pr_node_id: SecureRandom.uuid,
        pr_number: SecureRandom.random_number(100_000),
        pr_title: "The cat sat on the mat",
        earned_on: Time.current - SecureRandom.random_number(100_000).seconds
      }
    end
  end

  factory :user_code_merge_reputation_token, class: 'User::ReputationTokens::CodeMergeToken' do
    user
    level { :janitorial }

    params do
      {
        repo: "exercism/ruby",
        pr_node_id: SecureRandom.uuid,
        pr_number: SecureRandom.random_number(100_000),
        pr_title: "The cat sat on the mat",
        earned_on: Time.current - SecureRandom.random_number(100_000).seconds
      }
    end
  end

  factory :user_code_review_reputation_token, class: 'User::ReputationTokens::CodeReviewToken' do
    user
    level { :medium }

    params do
      {
        repo: "exercism/ruby",
        pr_node_id: SecureRandom.uuid,
        pr_number: SecureRandom.random_number(100_000),
        pr_title: "The cat sat on the mat",
        earned_on: Time.current - SecureRandom.random_number(100_000).seconds
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

  factory :user_concept_contribution_reputation_token, class: 'User::ReputationTokens::ConceptContributionToken' do
    user

    params do
      {
        contributorship: create(:concept_contributorship, contributor: user)
      }
    end
  end

  factory :user_concept_author_reputation_token, class: 'User::ReputationTokens::ConceptAuthorToken' do
    user

    params do
      {
        authorship: create(:concept_authorship, author: user)
      }
    end
  end

  factory :user_exercise_approach_introduction_author_reputation_token,
    class: 'User::ReputationTokens::ExerciseApproachIntroductionAuthorToken' do
    user

    params do
      {
        authorship: create(:exercise_approach_introduction_authorship, author: user)
      }
    end
  end

  factory :user_exercise_approach_introduction_contribution_reputation_token,
    class: 'User::ReputationTokens::ExerciseApproachIntroductionContributionToken' do
    user

    params do
      {
        contributorship: create(:exercise_approach_introduction_contributorship, contributor: user)
      }
    end
  end

  factory :user_mentored_reputation_token, class: 'User::ReputationTokens::MentoredToken' do
    user

    params do
      {
        discussion: create(:mentor_discussion, :mentor_finished, mentor: user)
      }
    end
  end

  factory :user_published_solution_reputation_token, class: 'User::ReputationTokens::PublishedSolutionToken' do
    user
    level { :medium }

    params do
      {
        solution: create(:practice_solution, :published, user:)
      }
    end
  end

  factory :user_issue_author_reputation_token, class: 'User::ReputationTokens::IssueAuthorToken' do
    user
    level { :large }

    params do
      {
        repo: "exercism/ruby",
        issue_node_id: SecureRandom.uuid,
        issue_number: SecureRandom.random_number(100_000),
        issue_title: "The cat sat on the mat",
        earned_on: Time.current - SecureRandom.random_number(100_000).seconds
      }
    end
  end

  factory :user_arbitrary_reputation_token, class: 'User::ReputationTokens::ArbitraryToken' do
    user

    params do
      {
        arbitrary_value: 23,
        arbitrary_reason: 'For helping troubleshoot'
      }
    end
  end

  factory :user_automation_feedback_author_reputation_token, class: 'User::ReputationTokens::AutomationFeedbackAuthorToken' do
    user

    params do
      {
        representation: create(:exercise_representation, :with_feedback, feedback_author: user)
      }
    end
  end

  trait :seen do
    seen { true }
  end

  trait :unseen do
    seen { false }
  end
end
