require "test_helper"

class Metric::QueueTest < ActiveSupport::TestCase
  test "queues log metric job" do
    type = :open_issue
    issue = create :github_issue
    occurred_at = Time.current - 2.seconds
    track = create :track
    user = create :user

    assert_enqueued_with(job: LogMetricJob) do
      Metric::Queue.(type, occurred_at, track:, user:, issue:)
    end
  end

  test "creates metric" do
    type = :open_issue
    occurred_at = Time.current - 2.seconds
    issue = create :github_issue
    track = create :track
    user = create :user

    perform_enqueued_jobs do
      Metric::Queue.(type, occurred_at, track:, user:, issue:)
    end

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal Metrics::OpenIssueMetric, metric.class
    assert_equal occurred_at, metric.occurred_at
    assert_equal track, metric.track
    assert_equal user, metric.user
  end

  test "does not crash when job fails metric" do
    type = :open_issue
    occurred_at = Time.current - 2.seconds
    issue = create :github_issue
    track = create :track
    user = create :user

    LogMetricJob.stubs(:perform_later).raises

    perform_enqueued_jobs do
      Metric::Queue.(type, occurred_at, track:, user:, issue:)
    end

    refute Metric.exists?
  end
end
