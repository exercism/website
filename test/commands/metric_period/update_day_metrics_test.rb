require "test_helper"

class MetricPeriod::UpdateDayMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "metrics are counted per action" do
    freeze_time do
      track = create :track
      create :start_solution_metric, track:, occurred_at: Time.current.beginning_of_day.prev_day
      create :finish_mentoring_metric, track:, occurred_at: Time.current.beginning_of_day.prev_day + 13.hours
      create :finish_mentoring_metric, track:, occurred_at: Time.current.beginning_of_day.prev_day + 8.hours
      create :open_issue_metric, track:, occurred_at: Time.current.beginning_of_day.prev_day + 5.hours

      MetricPeriod::UpdateDayMetrics.()

      assert_equal 1,
        MetricPeriod::Day.find_by(metric_type: Metrics::StartSolutionMetric.name, day: Time.current.prev_day.day, track:).count
      assert_equal 2,
        MetricPeriod::Day.find_by(metric_type: Metrics::FinishMentoringMetric.name, day: Time.current.prev_day.day, track:).count
      assert_equal 1,
        MetricPeriod::Day.find_by(metric_type: Metrics::OpenIssueMetric.name, day: Time.current.prev_day.day, track:).count
    end
  end

  test "metrics are counted per day" do
    freeze_time do
      track = create :track
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_day.prev_day, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_day.prev_day + 1.hour, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_day.prev_day + 10.hours, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_day.prev_day + 5.hours, track:)

      # Sanity check: two days ago should be ignored
      create(:start_solution_metric, occurred_at: Time.current - 2.days, track:)

      # Sanity check: current day should be ignored
      create(:start_solution_metric, occurred_at: Time.current, track:)

      MetricPeriod::UpdateDayMetrics.()

      assert_equal 4,
        MetricPeriod::Day.find_by(day: Time.current.prev_day.day, metric_type: Metrics::StartSolutionMetric.name, track:).count
    end
  end

  test "metrics are counted per track" do
    freeze_time do
      track_1 = create :track, :random_slug
      track_2 = create :track, :random_slug
      track_3 = create :track, :random_slug

      create :open_issue_metric, track: track_1, occurred_at: Time.current.beginning_of_day.prev_day
      create :open_issue_metric, track: track_2, occurred_at: Time.current.beginning_of_day.prev_day + 13.hours
      create :open_issue_metric, track: track_2, occurred_at: Time.current.beginning_of_day.prev_day + 8.hours
      create :open_issue_metric, track: track_2, occurred_at: Time.current.beginning_of_day.prev_day + 5.hours
      create :open_issue_metric, track: nil, occurred_at: Time.current.beginning_of_day.prev_day + 4.hours

      MetricPeriod::UpdateDayMetrics.()

      assert_equal 1,
        MetricPeriod::Day.find_by(track: track_1, metric_type: Metrics::OpenIssueMetric.name, day: Time.current.prev_day.day).count
      assert_equal 3,
        MetricPeriod::Day.find_by(track: track_2, metric_type: Metrics::OpenIssueMetric.name, day: Time.current.prev_day.day).count
      assert_equal 0,
        MetricPeriod::Day.find_by(track: track_3, metric_type: Metrics::OpenIssueMetric.name, day: Time.current.prev_day.day).count
      assert_equal 1,
        MetricPeriod::Day.find_by(track: nil, metric_type: Metrics::OpenIssueMetric.name, day: Time.current.prev_day.day).count
    end
  end

  test "updates count of existing metric" do
    freeze_time do
      track = create :track
      metric_period = create(:metric_period_day, metric_type: Metrics::OpenIssueMetric.name, day: Time.current.prev_day.day,
        count: 13, track:)

      7.times do
        create :open_issue_metric, track:, occurred_at: Time.current.prev_day
      end

      MetricPeriod::UpdateDayMetrics.()

      assert_equal 7, metric_period.reload.count
    end
  end

  test "count specific day" do
    freeze_time do
      # Normally these would be counted, but they'll be ignored in this test
      track = create :track
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_day.prev_day, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_day.prev_day + 1.hour, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_day.prev_day + 10.hours, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_day.prev_day + 5.hours, track:)

      # Sanity check: current day should be ignored
      create(:start_solution_metric, occurred_at: Time.current, track:)

      create(:start_solution_metric, occurred_at: Time.current - 2.days, track:)
      create(:start_solution_metric, occurred_at: Time.current - 2.days, track:)

      MetricPeriod::UpdateDayMetrics.(Time.current - 2.days)

      assert_equal 2,
        MetricPeriod::Day.find_by(day: (Time.current - 2.days).day, metric_type: Metrics::StartSolutionMetric.name, track:).count
    end
  end
end
