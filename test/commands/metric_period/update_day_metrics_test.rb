require "test_helper"

class MetricPeriod::UpdateDayMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "metrics are counted per action" do
    freeze_time do
      create :metric, metric_action: :publish_solution, created_at: Time.current.prev_day
      create :metric, metric_action: :finish_mentoring, created_at: Time.current.prev_day + 13.hours
      create :metric, metric_action: :finish_mentoring, created_at: Time.current.prev_day + 8.hours
      create :metric, metric_action: :open_issue, created_at: Time.current.prev_day + 5.hours

      MetricPeriod::UpdateDayMetrics.()

      assert_equal 1, MetricPeriod::Day.find_by(metric_action: :publish_solution, day: Time.current.prev_day.day).count
      assert_equal 2, MetricPeriod::Day.find_by(metric_action: :finish_mentoring, day: Time.current.prev_day.day).count
      assert_equal 1, MetricPeriod::Day.find_by(metric_action: :open_issue, day: Time.current.prev_day.day).count
    end
  end

  test "metrics are counted per day" do
    freeze_time do
      create :metric, created_at: Time.current.prev_day
      create :metric, created_at: Time.current.prev_day + 1.second
      create :metric, created_at: Time.current.prev_day + 10.hours
      create :metric, created_at: Time.current.prev_day + 5.hours

      # Sanity check: two days ago should be ignored
      create :metric, created_at: Time.current - 2.days

      # Sanity check: current day should be ignored
      create :metric, created_at: Time.current

      MetricPeriod::UpdateDayMetrics.()

      assert_equal 4, MetricPeriod::Day.find_by(day: Time.current.prev_day.day).count
    end
  end

  test "metrics are counted per track" do
    freeze_time do
      track_1 = create :track, :random_slug
      track_2 = create :track, :random_slug
      track_3 = create :track, :random_slug

      create :metric, track: track_1, created_at: Time.current.prev_day
      create :metric, track: track_2, created_at: Time.current.prev_day + 13.hours
      create :metric, track: track_2, created_at: Time.current.prev_day + 8.hours
      create :metric, track: track_2, created_at: Time.current.prev_day + 5.hours

      MetricPeriod::UpdateDayMetrics.()

      assert_equal 1, MetricPeriod::Day.find_by(track: track_1, day: Time.current.prev_day.day).count
      assert_equal 3, MetricPeriod::Day.find_by(track: track_2, day: Time.current.prev_day.day).count
      assert_equal 0, MetricPeriod::Day.find_by(track: track_3, day: Time.current.prev_day.day).count
    end
  end

  test "updates count of existing metric" do
    freeze_time do
      metric_period = create :metric_period_day, day: Time.current.prev_day.day, count: 13

      7.times do
        create :metric, metric_action: metric_period.metric_action, track: metric_period.track,
          created_at: Time.current.prev_day
      end

      MetricPeriod::UpdateDayMetrics.()

      assert_equal 7, metric_period.reload.count
    end
  end
end
