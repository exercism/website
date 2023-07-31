FactoryBot.define do
  factory :github_pull_request_review, class: 'Github::PullRequestReview' do
    pull_request { create :github_pull_request }
    node_id { "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4" }
    reviewer_username { "ErikSchierboom" }

    trait :random do
      pull_request { create :github_pull_request, :random }
      node_id { SecureRandom.hex }
    end

    transient do
      state { :closed }
    end

    before(:create) do |r, e|
      r.pull_request.update!(
        state: e.state,
        data: r.pull_request.data.tap do |d|
          d[:reviews] = [{ node_id: r.node_id, reviewer_username: r.reviewer_username }]
        end
      )
    end
  end
end
