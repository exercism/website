FactoryBot.define do
  factory :metric do
    occurred_at { Time.current }
    user { create :user }
    track do
      Track.find_by(slug: 'ruby') || build(:track, slug: 'ruby')
    end
  end

  factory :submit_solution_metric, parent: :metric, class: 'Metrics::SubmitSolutionMetric' do
    params { { solution: create(:practice_solution, track:) } }
  end

  factory :complete_solution_metric, parent: :metric, class: 'Metrics::CompleteSolutionMetric' do
    params { { solution: create(:practice_solution, track:) } }
  end

  factory :publish_solution_metric, parent: :metric, class: 'Metrics::PublishSolutionMetric' do
    params { { solution: create(:practice_solution, track:) } }
  end

  factory :finish_mentoring_metric, parent: :metric, class: 'Metrics::FinishMentoringMetric' do
    params { { discussion: create(:mentor_discussion, student: user) } }
  end

  factory :request_mentoring_metric, parent: :metric, class: 'Metrics::RequestMentoringMetric' do
    params { { request: create(:mentor_request, user:) } }
  end

  factory :open_pull_request_metric, parent: :metric, class: 'Metrics::OpenPullRequestMetric' do
    params { { issue: create(:github_pull_request, :random) } }
  end

  factory :merge_pull_request_metric, parent: :metric, class: 'Metrics::MergePullRequestMetric' do
    params { { issue: create(:github_pull_request, :random) } }
  end

  factory :open_issue_metric, parent: :metric, class: 'Metrics::OpenIssueMetric' do
    params { { issue: create(:github_issue, :random) } }
  end
end
