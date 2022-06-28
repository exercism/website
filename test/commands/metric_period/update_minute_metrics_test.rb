require "test_helper"

class MetricPeriod::UpdateMinuteMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "metrics are counted per action" do
    freeze_time do
      create :metric, metric_action: :publish_solution, occurred_at: Time.current.beginning_of_minute.prev_min
      create :metric, metric_action: :finish_mentoring, occurred_at: Time.current.beginning_of_minute.prev_min + 13.seconds
      create :metric, metric_action: :finish_mentoring, occurred_at: Time.current.beginning_of_minute.prev_min + 8.seconds
      create :metric, metric_action: :open_issue, occurred_at: Time.current.beginning_of_minute.prev_min + 55.seconds

      MetricPeriod::UpdateMinuteMetrics.()

      assert_equal 1, MetricPeriod::Minute.find_by(metric_action: :publish_solution, minute: Time.current.prev_min.min_of_day).count
      assert_equal 2, MetricPeriod::Minute.find_by(metric_action: :finish_mentoring, minute: Time.current.prev_min.min_of_day).count
      assert_equal 1, MetricPeriod::Minute.find_by(metric_action: :open_issue, minute: Time.current.prev_min.min_of_day).count
    end
  end

  test "metrics are counted per minute of the day" do
    freeze_time do
      create :metric, occurred_at: Time.current.beginning_of_minute.prev_min
      create :metric, occurred_at: Time.current.beginning_of_minute.prev_min + 1.second
      create :metric, occurred_at: Time.current.beginning_of_minute.prev_min + 10.seconds
      create :metric, occurred_at: Time.current.beginning_of_minute.prev_min + 59.seconds

      # Sanity check: two minutes ago should be ignored
      create :metric, occurred_at: Time.current.beginning_of_minute - 2.minutes

      # Sanity check: current minute should be ignored
      create :metric, occurred_at: Time.current.beginning_of_minute

      MetricPeriod::UpdateMinuteMetrics.()

      assert_equal 4, MetricPeriod::Minute.find_by(minute: Time.current.prev_min.min_of_day).count
    end
  end

  test "metrics are counted per track" do
    freeze_time do
      track_1 = create :track, :random_slug
      track_2 = create :track, :random_slug
      track_3 = create :track, :random_slug

      create :metric, track: track_1, occurred_at: Time.current.beginning_of_minute.prev_min
      create :metric, track: track_2, occurred_at: Time.current.beginning_of_minute.prev_min + 13.seconds
      create :metric, track: track_2, occurred_at: Time.current.beginning_of_minute.prev_min + 8.seconds
      create :metric, track: track_2, occurred_at: Time.current.beginning_of_minute.prev_min + 55.seconds

      MetricPeriod::UpdateMinuteMetrics.()

      assert_equal 1, MetricPeriod::Minute.find_by(track: track_1, minute: Time.current.prev_min.min_of_day).count
      assert_equal 3, MetricPeriod::Minute.find_by(track: track_2, minute: Time.current.prev_min.min_of_day).count
      assert_equal 0, MetricPeriod::Minute.find_by(track: track_3, minute: Time.current.prev_min.min_of_day).count
    end
  end

  test "count specific minute of the day" do
    freeze_time do
      # Normally these would be counted, but they'll be ignored in this test
      create :metric, occurred_at: Time.current.beginning_of_minute.prev_min
      create :metric, occurred_at: Time.current.beginning_of_minute.prev_min + 1.second
      create :metric, occurred_at: Time.current.beginning_of_minute.prev_min + 10.seconds
      create :metric, occurred_at: Time.current.beginning_of_minute.prev_min + 59.seconds

      create :metric, occurred_at: Time.current - 2.minutes
      create :metric, occurred_at: Time.current - 2.minutes

      # Sanity check: current minute should be ignored
      create :metric, occurred_at: Time.current.beginning_of_minute

      MetricPeriod::UpdateMinuteMetrics.(Time.current - 2.minutes)

      assert_equal 2, MetricPeriod::Minute.find_by(minute: (Time.current - 2.minutes).min_of_day).count
    end
  end

  test "updates count of existing metric" do
    freeze_time do
      metric_period = create :metric_period_minute, minute: Time.current.prev_min.min_of_day, count: 13

      7.times do
        create :metric, metric_action: metric_period.metric_action, track: metric_period.track,
          occurred_at: Time.current.beginning_of_minute.prev_min
      end

      MetricPeriod::UpdateMinuteMetrics.()

      assert_equal 7, metric_period.reload.count
    end
  end
end
