FactoryBot.define do
  factory :git_pull_request_review, class: 'Git::PullRequestReview' do
    pull_request { create :git_pull_request }
    node_id { "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4" }
    reviewer_github_username { "ErikSchierboom" }
  end
end
