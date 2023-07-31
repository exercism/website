require "test_helper"

class MetricPeriod::SearchTest < ActiveSupport::TestCase
  include Mandate

  test "filter: period_type" do
    day_1 = create :metric_period_day
    day_2 = create :metric_period_day
    month = create :metric_period_month
    minute_1 = create :metric_period_minute
    minute_2 = create :metric_period_minute

    assert_equal [day_1, day_2], MetricPeriod::Search.(:day, {}).order(:id)
    assert_equal [minute_1, minute_2], MetricPeriod::Search.(:minute, {}).order(:id)
    assert_equal [month], MetricPeriod::Search.(:month, {}).order(:id)
  end

  test "filter: period_begin" do
    period_1 = create :metric_period_day, day: 1
    period_2 = create :metric_period_day, day: 5
    period_3 = create :metric_period_day, day: 20
    period_4 = create :metric_period_day, day: 29

    assert_equal [period_1, period_2, period_3, period_4], MetricPeriod::Search.(:day, { period_begin: 1 }).order(:id)
    assert_equal [period_2, period_3, period_4], MetricPeriod::Search.(:day, { period_begin: 4 }).order(:id)
    assert_equal [period_4], MetricPeriod::Search.(:day, { period_begin: 22 }).order(:id)
    assert_empty MetricPeriod::Search.(:day, { period_begin: 30 }).order(:id)
  end

  test "filter: period_end" do
    period_1 = create :metric_period_day, day: 1
    period_2 = create :metric_period_day, day: 5
    period_3 = create :metric_period_day, day: 20
    period_4 = create :metric_period_day, day: 29

    assert_equal [period_1], MetricPeriod::Search.(:day, { period_end: 1 }).order(:day)
    assert_equal [period_1, period_2], MetricPeriod::Search.(:day, { period_end: 7 }).order(:day)
    assert_equal [period_1, period_2, period_3], MetricPeriod::Search.(:day, { period_end: 22 }).order(:day)
    assert_equal [period_1, period_2, period_3, period_4], MetricPeriod::Search.(:day, { period_end: 30 }).order(:day)
  end

  test "filter: track_slug" do
    track_1 = create :track, slug: 'ruby'
    track_2 = create :track, slug: 'csharp'
    period_1 = create :metric_period_day, track: track_1, day: 1
    period_2 = create :metric_period_day, track: track_1, day: 2
    period_3 = create :metric_period_day, track: nil, day: 3
    period_4 = create :metric_period_day, track: track_2, day: 4

    assert_equal [period_1, period_2, period_3, period_4], MetricPeriod::Search.(:day, { track_slug: '' }).order(:day)
    assert_equal [period_1, period_2], MetricPeriod::Search.(:day, { track_slug: 'ruby' }).order(:day)
    assert_equal [period_4], MetricPeriod::Search.(:day, { track_slug: 'csharp' }).order(:day)
  end

  test "filter: metric_type" do
    period_1 = create :metric_period_day, metric_type: Metrics::OpenIssueMetric.name, day: 1
    period_2 = create :metric_period_day, metric_type: Metrics::RequestMentoringMetric.name, day: 2
    period_3 = create :metric_period_day, metric_type: Metrics::StartSolutionMetric.name, day: 3
    period_4 = create :metric_period_day, metric_type: Metrics::StartSolutionMetric.name, day: 4

    assert_empty MetricPeriod::Search.(:day, { metric_type: 'complete_solution_metric' }).order(:day)
    assert_equal [period_1], MetricPeriod::Search.(:day, { metric_type: 'open_issue_metric' }).order(:day)
    assert_equal [period_2], MetricPeriod::Search.(:day, { metric_type: 'request_mentoring_metric' })
    assert_equal [period_3, period_4], MetricPeriod::Search.(:day, { metric_type: 'start_solution_metric' })
  end
end
