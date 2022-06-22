require "test_helper"

class LogMetricJobTest < ActiveJob::TestCase
  test "creates metric" do
    action = :open_issue
    created_at = Time.current - 3.seconds
    track = create :track
    user = create :user

    LogMetricJob.perform_now(action, created_at, track:, user:)

    metric = Metric.last
    assert_equal action, metric.metric_action
    assert_equal created_at, metric.created_at
    assert_equal track, metric.track
    assert_equal user, metric.user
  end
end
