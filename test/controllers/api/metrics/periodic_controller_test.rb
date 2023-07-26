require_relative '../base_test_case'

class API::Metrics::PeriodicControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_metrics_periodic_url

  test "index should filter correctly" do
    setup_user

    track = create :track, slug: 'ruby'
    create(:metric_period_day, metric_type: Metrics::OpenIssueMetric.name, day: 2, count: 13, track:)
    create :metric_period_day, metric_type: Metrics::RequestMentoringMetric.name, day: 11, count: 9, track: nil
    create(:metric_period_day, metric_type: Metrics::CompleteSolutionMetric.name, day: 22, count: 55, track:)
    create(:metric_period_minute, metric_type: Metrics::RequestMentoringMetric.name, minute: 14, count: 2, track:)
    create :metric_period_day, metric_type: Metrics::StartSolutionMetric.name, day: 28, count: 0, track: nil

    get api_metrics_periodic_url(
      period_type: "day",
      period_begin: "10",
      period_end: "25"
    ), headers: @headers, as: :json
    assert_response 200

    expected = { data: [
      { count: 9, track_slug: nil, type: 'request_mentoring_metric', day: 11 },
      { count: 55, track_slug: 'ruby', type: 'complete_solution_metric', day: 22 }
    ] }.to_json
    assert_equal expected, response.body
  end

  test "index returns 400 when not passing any parameters" do
    setup_user

    get api_metrics_periodic_url, headers: @headers, as: :json
    assert_response 400
  end

  test "index returns 400 when passing unknown period type" do
    setup_user

    get api_metrics_periodic_url(
      period_type: "weekly"
    ), headers: @headers, as: :json
    assert_response 400
  end

  test "index returns 400 when passing unknown metric type" do
    setup_user

    get api_metrics_periodic_url(
      period_type: "day",
      metric_type: "UnknownMetricType"
    ), headers: @headers, as: :json
    assert_response 400
  end
end
