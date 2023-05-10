require "test_helper"

class MetricPeriod::UpdateMonthMetricsTest < ActiveSupport::TestCase
  include Mandate

  test "metrics are counted per action" do
    freeze_time do
      track = create :track
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_month.prev_month, track:)
      create(:finish_mentoring_metric, occurred_at: Time.current.beginning_of_month.prev_month + 13.days, track:)
      create(:finish_mentoring_metric, occurred_at: Time.current.beginning_of_month.prev_month + 8.days, track:)
      create(:open_issue_metric, occurred_at: Time.current.beginning_of_month.prev_month + 5.days, track:)

      MetricPeriod::UpdateMonthMetrics.()

      assert_equal 1,
        MetricPeriod::Month.find_by(metric_type: Metrics::StartSolutionMetric.name, month: Time.current.prev_month.month,
          track:).count
      assert_equal 2,
        MetricPeriod::Month.find_by(metric_type: Metrics::FinishMentoringMetric.name, month: Time.current.prev_month.month,
          track:).count
      assert_equal 1,
        MetricPeriod::Month.find_by(metric_type: Metrics::OpenIssueMetric.name, month: Time.current.prev_month.month, track:).count
    end
  end

  test "metrics are counted per month" do
    freeze_time do
      track = create :track
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_month.prev_month, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_month.prev_month + 1.day, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_month.prev_month + 10.days, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_month.prev_month + 5.days, track:)

      # Sanity check: two months ago should be ignored
      create(:start_solution_metric, occurred_at: Time.current - 2.months, track:)

      # Sanity check: current month should be ignored
      create(:start_solution_metric, occurred_at: Time.current, track:)

      MetricPeriod::UpdateMonthMetrics.()

      assert_equal 4,
        MetricPeriod::Month.find_by(month: Time.current.prev_month.month, metric_type: Metrics::StartSolutionMetric.name,
          track:).count
    end
  end

  test "metrics are counted per track" do
    freeze_time do
      track_1 = create :track, :random_slug
      track_2 = create :track, :random_slug
      track_3 = create :track, :random_slug

      create :open_issue_metric, track: track_1, occurred_at: Time.current.beginning_of_month.prev_month
      create :open_issue_metric, track: track_2, occurred_at: Time.current.beginning_of_month.prev_month + 13.days
      create :open_issue_metric, track: track_2, occurred_at: Time.current.beginning_of_month.prev_month + 8.days
      create :open_issue_metric, track: track_2, occurred_at: Time.current.beginning_of_month.prev_month + 5.days
      create :open_issue_metric, track: nil, occurred_at: Time.current.beginning_of_month.prev_month + 5.days

      MetricPeriod::UpdateMonthMetrics.()

      assert_equal 1,
        MetricPeriod::Month.find_by(track: track_1, month: Time.current.prev_month.month,
          metric_type: Metrics::OpenIssueMetric.name).count
      assert_equal 3,
        MetricPeriod::Month.find_by(track: track_2, month: Time.current.prev_month.month,
          metric_type: Metrics::OpenIssueMetric.name).count
      assert_equal 0,
        MetricPeriod::Month.find_by(track: track_3, month: Time.current.prev_month.month,
          metric_type: Metrics::OpenIssueMetric.name).count
      assert_equal 1,
        MetricPeriod::Month.find_by(track: nil, month: Time.current.prev_month.month, metric_type: Metrics::OpenIssueMetric.name).count
    end
  end

  test "count specific month" do
    freeze_time do
      track = create :track

      # Normally these would be counted, but they'll be ignored in this test
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_month.prev_month, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_month.prev_month + 1.day, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_month.prev_month + 10.days, track:)
      create(:start_solution_metric, occurred_at: Time.current.beginning_of_month.prev_month + 5.days, track:)

      create(:start_solution_metric, occurred_at: Time.current - 2.months, track:)
      create(:start_solution_metric, occurred_at: Time.current - 2.months, track:)

      # Sanity check: current month should be ignored
      create(:start_solution_metric, occurred_at: Time.current, track:)

      MetricPeriod::UpdateMonthMetrics.(Time.current - 2.months)

      assert_equal 2,
        MetricPeriod::Month.find_by(month: (Time.current - 2.months).month, track:,
          metric_type: Metrics::StartSolutionMetric.name).count
    end
  end

  test "updates count of existing metric" do
    freeze_time do
      track = create :track
      metric_period = create :metric_period_month, metric_type: Metrics::OpenIssueMetric.name, track:,
        month: Time.current.prev_month.month, count: 13

      7.times do
        create :open_issue_metric, track:, occurred_at: Time.current.prev_month
      end

      MetricPeriod::UpdateMonthMetrics.()

      assert_equal 7, metric_period.reload.count
    end
  end
end
