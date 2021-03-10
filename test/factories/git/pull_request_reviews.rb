FactoryBot.define do
  factory :git_pull_request_review, class: 'Git::PullRequestReview' do
    pull_request { create :git_pull_request }
    node_id { "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4" }
    reviewer_github_username { "ErikSchierboom" }

    trait :random do
      pull_request { create :git_pull_request, :random }
      node_id { SecureRandom.hex }

      after(:build) do |r|
        r.pull_request.update!(
          data: r.pull_request.data.tap do |d|
            d[:reviews] = [{ node_id: r.node_id, reviewer: r.reviewer_github_username }]
          end
        )
      end
    end
  end
end
