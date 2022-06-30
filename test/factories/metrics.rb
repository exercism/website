FactoryBot.define do
  factory :metric do
    occurred_at { Time.current }
    user { create :user }
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end
  end

  factory :submit_solution_metric, parent: :metric, class: 'Metrics::SubmitSolution' do
    params { { solution: create(:practice_solution) } }
  end

  factory :complete_solution_metric, parent: :metric, class: 'Metrics::CompleteSolution' do
    params { { solution: create(:practice_solution) } }
  end

  factory :publish_solution_metric, parent: :metric, class: 'Metrics::PublishSolution' do
    params { { solution: create(:practice_solution) } }
  end

  factory :finish_mentoring_metric, parent: :metric, class: 'Metrics::FinishMentoring' do
    params { { discussion: create(:mentor_discussion, student: user) } }
  end

  factory :request_mentoring_metric, parent: :metric, class: 'Metrics::RequestMentoring' do
    params { { request: create(:mentor_request, user:) } }
  end

  factory :open_pull_request_metric, parent: :metric, class: 'Metrics::OpenPullRequest' do
    params { { issue: create(:github_pull_request) } }
  end

  factory :merge_pull_request_metric, parent: :metric, class: 'Metrics::MergePullRequest' do
    params { { issue: create(:github_pull_request) } }
  end

  factory :open_issue_metric, parent: :metric, class: 'Metrics::OpenIssue' do
    params { { issue: create(:github_issue) } }
  end
end
