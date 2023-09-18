require "test_helper"

class MetricPeriod::UpdateLastHourMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "calculate metrics for last hour" do
    freeze_time do
      track = create :track
      create :publish_solution_metric, track:, occurred_at: Time.current.prev_min
      create :finish_mentoring_metric, track:, occurred_at: Time.current.prev_min - 44.minutes
      create :finish_mentoring_metric, track:, occurred_at: Time.current.prev_min - 44.minutes
      create :open_issue_metric, track:, occurred_at: Time.current.prev_min - 59.minutes

      MetricPeriod::UpdateLastHourMetrics.()

      assert_equal 1, MetricPeriod::Minute.find_by(metric_type: Metrics::PublishSolutionMetric.name, minute: Time.current.prev_min.min_of_day, track:).count # rubocop:disable Layout/LineLength
      assert_equal 2, MetricPeriod::Minute.find_by(metric_type: Metrics::FinishMentoringMetric.name, minute: (Time.current.prev_min - 44.minutes).min_of_day, track:).count # rubocop:disable Layout/LineLength
      assert_equal 1, MetricPeriod::Minute.find_by(metric_type: Metrics::OpenIssueMetric.name, minute: (Time.current.prev_min - 59.minutes).min_of_day, track:).count # rubocop:disable Layout/LineLength
    end
  end
end
