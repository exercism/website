require "test_helper"

class LogMetricJobTest < ActiveJob::TestCase
  test "creates metric" do
    freeze_time do
      type = :open_issue
      issue = create :github_issue
      occurred_at = Time.current - 3.seconds
      remote_ip = '127.0.0.1'
      track = create :track
      user = create :user

      LogMetricJob.perform_now(type, occurred_at, remote_ip:, track:, user:, issue:)

      metric = Metric.last
      assert_equal Metrics::OpenIssueMetric, metric.class
      assert_equal occurred_at, metric.occurred_at
      assert_equal 'US', metric.country_code
      assert_equal Time.current, metric.created_at
      assert_equal Time.current, metric.updated_at
      assert_equal track, metric.track
      assert_equal user, metric.user
    end
  end
end
