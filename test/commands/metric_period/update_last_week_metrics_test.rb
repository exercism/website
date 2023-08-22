require "test_helper"

class MetricPeriod::UpdateLastHourMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "calculate metrics for last week" do
    freeze_time do
      track = create :track
      create :publish_solution_metric, track:, occurred_at: Time.current.prev_day
      create :finish_mentoring_metric, track:, occurred_at: Time.current.prev_day - 2.days
      create :finish_mentoring_metric, track:, occurred_at: Time.current.prev_day - 2.days
      create :open_issue_metric, track:, occurred_at: Time.current.prev_day - 5.days

      MetricPeriod::UpdateLastWeekMetrics.()

      assert_equal 1, MetricPeriod::Day.find_by(metric_type: Metrics::PublishSolutionMetric.name, day: Time.current.prev_day.day, track:).count # rubocop:disable Layout/LineLength
      assert_equal 2, MetricPeriod::Day.find_by(metric_type: Metrics::FinishMentoringMetric.name, day: (Time.current.prev_day - 2.days).day, track:).count # rubocop:disable Layout/LineLength
      assert_equal 1, MetricPeriod::Day.find_by(metric_type: Metrics::OpenIssueMetric.name, day: (Time.current.prev_day - 5.days).day, track:).count # rubocop:disable Layout/LineLength
    end
  end
end
