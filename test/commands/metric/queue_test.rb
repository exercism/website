require "test_helper"

class Metric::QueueTest < ActiveSupport::TestCase
  test "queues log metric job" do
    action = :request_mentoring
    created_at = Time.current - 2.seconds
    country_code = 'BE'
    track = create :track
    user = create :user

    assert_enqueued_with(job: LogMetricJob) do
      Metric::Queue.(action, created_at, country_code:, track:, user:)
    end
  end

  test "creates metric" do
    action = :request_mentoring
    created_at = Time.current - 2.seconds
    country_code = 'BE'
    track = create :track
    user = create :user

    perform_enqueued_jobs do
      Metric::Queue.(action, created_at, country_code:, track:, user:)
    end

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal action, metric.action
    assert_equal created_at, metric.created_at
    assert_equal country_code, metric.country_code
    assert_equal track, metric.track
    assert_equal user, metric.user
  end

  test "does not crash when job fails metric" do
    action = :request_mentoring
    created_at = Time.current - 2.seconds
    country_code = 'BE'
    track = create :track
    user = create :user

    LogMetricJob.stubs(:perform_later).raises

    perform_enqueued_jobs do
      Metric::Queue.(action, created_at, country_code:, track:, user:)
    end

    refute Metric.exists?
  end
end
