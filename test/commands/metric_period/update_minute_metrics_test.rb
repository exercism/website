require "test_helper"

class MetricPeriod::UpdateMinuteMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "metrics are counted per action" do
    freeze_time do
      track = create :track
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute.prev_min, track: track
      create :finish_mentoring_metric, occurred_at: Time.current.beginning_of_minute.prev_min + 13.seconds, track: track
      create :finish_mentoring_metric, occurred_at: Time.current.beginning_of_minute.prev_min + 8.seconds, track: track
      create :open_issue_metric, occurred_at: Time.current.beginning_of_minute.prev_min + 55.seconds, track: track

      MetricPeriod::UpdateMinuteMetrics.()

      assert_equal 1,
        MetricPeriod::Minute.find_by(metric_type: Metrics::SubmitSolutionMetric.name, minute: Time.current.prev_min.min_of_day,
          track:).count
      assert_equal 2,
        MetricPeriod::Minute.find_by(metric_type: Metrics::FinishMentoringMetric.name, minute: Time.current.prev_min.min_of_day,
          track:).count
      assert_equal 1,
        MetricPeriod::Minute.find_by(metric_type: Metrics::OpenIssueMetric.name, minute: Time.current.prev_min.min_of_day,
          track:).count
    end
  end

  test "metrics are counted per minute of the day" do
    freeze_time do
      track = create :track
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute.prev_min, track: track
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute.prev_min + 1.second, track: track
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute.prev_min + 10.seconds, track: track
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute.prev_min + 59.seconds, track: track

      # Sanity check: two minutes ago should be ignored
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute - 2.minutes, track: track

      # Sanity check: current minute should be ignored
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute, track: track

      MetricPeriod::UpdateMinuteMetrics.()

      assert_equal 4,
        MetricPeriod::Minute.find_by(minute: Time.current.prev_min.min_of_day, metric_type: Metrics::SubmitSolutionMetric.name,
          track:).count
    end
  end

  test "metrics are counted per track" do
    freeze_time do
      track_1 = create :track, :random_slug
      track_2 = create :track, :random_slug
      track_3 = create :track, :random_slug

      create :open_issue_metric, track: track_1, occurred_at: Time.current.beginning_of_minute.prev_min
      create :open_issue_metric, track: track_2, occurred_at: Time.current.beginning_of_minute.prev_min + 13.seconds
      create :open_issue_metric, track: track_2, occurred_at: Time.current.beginning_of_minute.prev_min + 8.seconds
      create :open_issue_metric, track: track_2, occurred_at: Time.current.beginning_of_minute.prev_min + 55.seconds
      create :open_issue_metric, track: nil, occurred_at: Time.current.beginning_of_minute.prev_min + 55.seconds

      MetricPeriod::UpdateMinuteMetrics.()

      assert_equal 1,
        MetricPeriod::Minute.find_by(track: track_1, minute: Time.current.prev_min.min_of_day,
          metric_type: Metrics::OpenIssueMetric.name).count
      assert_equal 3,
        MetricPeriod::Minute.find_by(track: track_2, minute: Time.current.prev_min.min_of_day,
          metric_type: Metrics::OpenIssueMetric.name).count
      assert_equal 0,
        MetricPeriod::Minute.find_by(track: track_3, minute: Time.current.prev_min.min_of_day,
          metric_type: Metrics::OpenIssueMetric.name).count
      assert_equal 1,
        MetricPeriod::Minute.find_by(track: nil, minute: Time.current.prev_min.min_of_day,
          metric_type: Metrics::OpenIssueMetric.name).count
    end
  end

  test "count specific minute of the day" do
    freeze_time do
      track = create :track

      # Normally these would be counted, but they'll be ignored in this test
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute.prev_min, track: track
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute.prev_min + 1.second, track: track
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute.prev_min + 10.seconds, track: track
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute.prev_min + 59.seconds, track: track

      create :submit_solution_metric, occurred_at: Time.current - 2.minutes, track: track
      create :submit_solution_metric, occurred_at: Time.current - 2.minutes, track: track

      # Sanity check: current minute should be ignored
      create :submit_solution_metric, occurred_at: Time.current.beginning_of_minute, track: track

      MetricPeriod::UpdateMinuteMetrics.(Time.current - 2.minutes)

      assert_equal 2,
        MetricPeriod::Minute.find_by(minute: (Time.current - 2.minutes).min_of_day, metric_type: Metrics::SubmitSolutionMetric.name,
          track:).count
    end
  end

  test "updates count of existing metric" do
    freeze_time do
      track = create :track
      metric_period = create :metric_period_minute, metric_type: Metrics::OpenIssueMetric.name, track: track,
        minute: Time.current.prev_min.min_of_day, count: 13

      7.times do
        create :open_issue_metric, track:, occurred_at: Time.current.beginning_of_minute.prev_min
      end

      MetricPeriod::UpdateMinuteMetrics.()

      assert_equal 7, metric_period.reload.count
    end
  end
end
