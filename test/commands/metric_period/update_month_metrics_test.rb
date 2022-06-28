require "test_helper"

class MetricPeriod::UpdateMonthMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "metrics are counted per action" do
    freeze_time do
      create :metric, metric_action: :publish_solution, occurred_at: Time.current.beginning_of_month.prev_month
      create :metric, metric_action: :finish_mentoring, occurred_at: Time.current.beginning_of_month.prev_month + 13.days
      create :metric, metric_action: :finish_mentoring, occurred_at: Time.current.beginning_of_month.prev_month + 8.days
      create :metric, metric_action: :open_issue, occurred_at: Time.current.beginning_of_month.prev_month + 5.days

      MetricPeriod::UpdateMonthMetrics.()

      assert_equal 1, MetricPeriod::Month.find_by(metric_action: :publish_solution, month: Time.current.prev_month.month).count
      assert_equal 2, MetricPeriod::Month.find_by(metric_action: :finish_mentoring, month: Time.current.prev_month.month).count
      assert_equal 1, MetricPeriod::Month.find_by(metric_action: :open_issue, month: Time.current.prev_month.month).count
    end
  end

  test "metrics are counted per month" do
    freeze_time do
      create :metric, occurred_at: Time.current.beginning_of_month.prev_month
      create :metric, occurred_at: Time.current.beginning_of_month.prev_month + 1.day
      create :metric, occurred_at: Time.current.beginning_of_month.prev_month + 10.days
      create :metric, occurred_at: Time.current.beginning_of_month.prev_month + 5.days

      # Sanity check: two months ago should be ignored
      create :metric, occurred_at: Time.current - 2.months

      # Sanity check: current month should be ignored
      create :metric, occurred_at: Time.current

      MetricPeriod::UpdateMonthMetrics.()

      assert_equal 4, MetricPeriod::Month.find_by(month: Time.current.prev_month.month).count
    end
  end

  test "metrics are counted per track" do
    freeze_time do
      track_1 = create :track, :random_slug
      track_2 = create :track, :random_slug
      track_3 = create :track, :random_slug

      create :metric, track: track_1, occurred_at: Time.current.beginning_of_month.prev_month
      create :metric, track: track_2, occurred_at: Time.current.beginning_of_month.prev_month + 13.days
      create :metric, track: track_2, occurred_at: Time.current.beginning_of_month.prev_month + 8.days
      create :metric, track: track_2, occurred_at: Time.current.beginning_of_month.prev_month + 5.days

      MetricPeriod::UpdateMonthMetrics.()

      assert_equal 1, MetricPeriod::Month.find_by(track: track_1, month: Time.current.prev_month.month).count
      assert_equal 3, MetricPeriod::Month.find_by(track: track_2, month: Time.current.prev_month.month).count
      assert_equal 0, MetricPeriod::Month.find_by(track: track_3, month: Time.current.prev_month.month).count
    end
  end

  test "count specific month" do
    freeze_time do
      # Normally these would be counted, but they'll be ignored in this test
      create :metric, occurred_at: Time.current.beginning_of_month.prev_month
      create :metric, occurred_at: Time.current.beginning_of_month.prev_month + 1.day
      create :metric, occurred_at: Time.current.beginning_of_month.prev_month + 10.days
      create :metric, occurred_at: Time.current.beginning_of_month.prev_month + 5.days

      create :metric, occurred_at: Time.current - 2.months
      create :metric, occurred_at: Time.current - 2.months

      # Sanity check: current month should be ignored
      create :metric, occurred_at: Time.current

      MetricPeriod::UpdateMonthMetrics.(Time.current - 2.months)

      assert_equal 2, MetricPeriod::Month.find_by(month: (Time.current - 2.months).month).count
    end
  end

  test "updates count of existing metric" do
    freeze_time do
      metric_period = create :metric_period_month, month: Time.current.prev_month.month, count: 13

      7.times do
        create :metric, metric_action: metric_period.metric_action, track: metric_period.track,
          occurred_at: Time.current.prev_month
      end

      MetricPeriod::UpdateMonthMetrics.()

      assert_equal 7, metric_period.reload.count
    end
  end
end
