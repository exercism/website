require "test_helper"

class MetricPeriod::UpdateLastHourMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "calculate metrics for last hour" do
    freeze_time do
      create :metric, metric_action: :publish_solution, occurred_at: Time.current.prev_min
      create :metric, metric_action: :finish_mentoring, occurred_at: Time.current.prev_min - 44.minutes
      create :metric, metric_action: :finish_mentoring, occurred_at: Time.current.prev_min - 44.minutes
      create :metric, metric_action: :open_issue, occurred_at: Time.current.prev_min - 59.minutes

      MetricPeriod::UpdateLastHourMetrics.()

      assert_equal 1, MetricPeriod::Minute.find_by(metric_action: :publish_solution, minute: Time.current.prev_min.min_of_day).count
      assert_equal 2,
        MetricPeriod::Minute.find_by(metric_action: :finish_mentoring, minute: (Time.current.prev_min - 44.minutes).min_of_day).count
      assert_equal 1,
        MetricPeriod::Minute.find_by(metric_action: :open_issue, minute: (Time.current.prev_min - 59.minutes).min_of_day).count
    end
  end
end
