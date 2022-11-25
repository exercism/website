FactoryBot.define do
  factory :metric, class: 'Metrics::StartSolutionMetric' do
    params { { solution: create(:practice_solution, track:) } }
    occurred_at { Time.current }
    user { create :user }
    country_code { 'DE' }
    track do
      Track.find_by(slug: 'ruby') || build(:track, slug: 'ruby')
    end
  end

  factory :start_solution_metric, parent: :metric, class: 'Metrics::StartSolutionMetric' do
    params { { solution: create(:practice_solution, track:) } }
  end

  factory :complete_solution_metric, parent: :metric, class: 'Metrics::CompleteSolutionMetric' do
    params { { solution: create(:practice_solution, track:) } }
  end

  factory :publish_solution_metric, parent: :metric, class: 'Metrics::PublishSolutionMetric' do
    params { { solution: create(:practice_solution, track:) } }
  end

  factory :finish_mentoring_metric, parent: :metric, class: 'Metrics::FinishMentoringMetric' do
    params { { discussion: create(:mentor_discussion, student: user, solution: create(:practice_solution, track:)) } }
  end

  factory :request_mentoring_metric, parent: :metric, class: 'Metrics::RequestMentoringMetric' do
    params { { request: create(:mentor_request, student: user, solution: create(:practice_solution, track:)) } }
  end

  factory :request_private_mentoring_metric, parent: :metric, class: 'Metrics::RequestPrivateMentoringMetric' do
    params { { request: create(:mentor_request, student: user, solution: create(:practice_solution, track:)) } }
  end

  factory :open_pull_request_metric, parent: :metric, class: 'Metrics::OpenPullRequestMetric' do
    params { { pull_request: create(:github_pull_request, :random) } }
  end

  factory :merge_pull_request_metric, parent: :metric, class: 'Metrics::MergePullRequestMetric' do
    params { { pull_request: create(:github_pull_request, :random) } }
  end

  factory :open_issue_metric, parent: :metric, class: 'Metrics::OpenIssueMetric' do
    params { { issue: create(:github_issue, :random) } }
  end

  factory :join_track_metric, parent: :metric, class: 'Metrics::JoinTrackMetric' do
    params { { user_track: create(:user_track, track:, user:) } }
  end
end
