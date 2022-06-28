require "test_helper"

class LogMetricJobTest < ActiveJob::TestCase
  test "creates metric" do
    freeze_time do
      action = :open_issue
      occurred_at = Time.current - 3.seconds
      track = create :track
      user = create :user

      LogMetricJob.perform_now(action, occurred_at, track:, user:)

      metric = Metric.last
      assert_equal action, metric.metric_action
      assert_equal occurred_at, metric.occurred_at
      assert_equal Time.current, metric.created_at
      assert_equal Time.current, metric.updated_at
      assert_equal track, metric.track
      assert_equal user, metric.user
    end
  end
end
