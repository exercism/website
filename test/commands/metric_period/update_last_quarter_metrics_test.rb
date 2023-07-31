require "test_helper"

class MetricPeriod::UpdateLastQuarterMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "calculate metrics for last quarter" do
    freeze_time do
      track = create :track
      create :publish_solution_metric, track:, occurred_at: Time.current.prev_month
      create :finish_mentoring_metric, track:, occurred_at: Time.current.prev_month - 1.month
      create :finish_mentoring_metric, track:, occurred_at: Time.current.prev_month - 1.month
      create :open_issue_metric, track:, occurred_at: Time.current.prev_month - 2.months

      MetricPeriod::UpdateLastQuarterMetrics.()

      assert_equal 1, MetricPeriod::Month.find_by(metric_type: Metrics::PublishSolutionMetric.name, month: Time.current.prev_month.month, track:).count # rubocop:disable Layout/LineLength
      assert_equal 2, MetricPeriod::Month.find_by(metric_type: Metrics::FinishMentoringMetric.name, month: (Time.current.prev_month - 1.month).month, track:).count # rubocop:disable Layout/LineLength
      assert_equal 1, MetricPeriod::Month.find_by(metric_type: Metrics::OpenIssueMetric.name, month: (Time.current.prev_month - 2.months).month, track:).count # rubocop:disable Layout/LineLength
    end
  end
end
