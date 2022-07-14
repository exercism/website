require "test_helper"

class LogMetricJobTest < ActiveJob::TestCase
  test "creates metric" do
    freeze_time do
      type = :open_issue
      issue = create :github_issue
      occurred_at = Time.current - 3.seconds
      country_code = 'KE'
      track = create :track
      user = create :user

      LogMetricJob.perform_now(type, occurred_at, country_code, track:, user:, issue:)

      metric = Metric.last
      assert_equal Metrics::OpenIssueMetric, metric.class
      assert_equal occurred_at, metric.occurred_at
      assert_equal country_code, metric.country_code
      assert_equal Time.current, metric.created_at
      assert_equal Time.current, metric.updated_at
      assert_equal track, metric.track
      assert_equal user, metric.user
    end
  end
end
