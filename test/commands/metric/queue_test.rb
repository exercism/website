require "test_helper"

class Metric::QueueTest < ActiveSupport::TestCase
  test "queues log metric job" do
    issue = create :github_issue
    track = create :track
    user = create :user

    assert_enqueued_with(job: LogMetricJob) do
      Metric::Queue.(:open_issue, Time.current, track:, user:, issue:)
    end
  end

  test "queues log metric job without user" do
    issue = create :github_issue
    track = create :track

    assert_enqueued_with(job: LogMetricJob) do
      Metric::Queue.(:open_issue, Time.current, track:, issue:)
    end
  end

  test "queues log metric job with nil user" do
    issue = create :github_issue
    track = create :track

    assert_enqueued_with(job: LogMetricJob) do
      Metric::Queue.(:open_issue, Time.current, user: nil, track:, issue:)
    end
  end

  test "queues log metric job without track" do
    issue = create :github_issue
    user = create :user

    assert_enqueued_with(job: LogMetricJob) do
      Metric::Queue.(:open_issue, Time.current, user:, issue:)
    end
  end

  test "don't queue log metric job if the user is the system user" do
    issue = create :github_issue
    track = create :track
    user = create :user, :system

    assert_no_enqueued_jobs do
      Metric::Queue.(:open_issue, Time.current, track:, user:, issue:)
    end
  end

  test "don't queue log metric job if the user is the ghost user" do
    issue = create :github_issue
    track = create :track
    user = create :user, :ghost

    assert_no_enqueued_jobs do
      Metric::Queue.(:open_issue, Time.current, track:, user:, issue:)
    end
  end

  test "creates metric" do
    type = :submit_solution
    solution = create :concept_solution
    occurred_at = Time.current - 3.seconds
    track = solution.track
    user = solution.user

    perform_enqueued_jobs do
      Metric::Queue.(type, occurred_at, track:, user:, solution:)
    end

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal Metrics::SubmitSolutionMetric, metric.class
    assert_equal occurred_at, metric.occurred_at
    assert_equal 'US', metric.country_code
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
