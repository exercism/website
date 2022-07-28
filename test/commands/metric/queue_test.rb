require "test_helper"

class Metric::QueueTest < ActiveSupport::TestCase
  test "queues log metric job" do
    issue = create :github_issue
    track = create :track
    user = create :user

    assert_enqueued_with(job: MandateJob,
      args: [Metric::Create.name, :open_issue, Time.current, { track:, user:, issue:, request_context: Exercism.request_context }]) do
      Metric::Queue.(:open_issue, Time.current, track:, user:, issue:)
    end
  end

  test "queues log metric job without user" do
    issue = create :github_issue
    track = create :track

    assert_enqueued_with(job: MandateJob,
      args: [Metric::Create.name, :open_issue, Time.current, { track:, issue:, request_context: Exercism.request_context }]) do
      Metric::Queue.(:open_issue, Time.current, track:, issue:)
    end
  end

  test "queues log metric job with nil user" do
    issue = create :github_issue
    track = create :track

    assert_enqueued_with(job: MandateJob,
      args: [Metric::Create.name, :open_issue, Time.current,
             { track:, user: nil, issue:, request_context: Exercism.request_context }]) do
      Metric::Queue.(:open_issue, Time.current, user: nil, track:, issue:)
    end
  end

  test "queues log metric job without track" do
    issue = create :github_issue
    user = create :user

    assert_enqueued_with(job: MandateJob,
      args: [Metric::Create.name, :open_issue, Time.current, { user:, issue:, request_context: Exercism.request_context }]) do
      Metric::Queue.(:open_issue, Time.current, user:, issue:)
    end
  end

  test "don't queue log metric job if the user is the system user" do
    issue = create :github_issue
    track = create :track
    user = create :user, :system

    assert_no_enqueued_jobs do
      Metric::Queue.(:open_issue, Time.current, track:, user:, issue:, request_context: Exercism.request_context)
    end
  end

  test "don't queue log metric job if the user is the ghost user" do
    issue = create :github_issue
    track = create :track
    user = create :user, :ghost

    assert_no_enqueued_jobs do
      Metric::Queue.(:open_issue, Time.current, track:, user:, issue:, request_context: Exercism.request_context)
    end
  end

  test "does not crash when metric creation fails" do
    type = :open_issue
    occurred_at = Time.current - 2.seconds
    issue = create :github_issue
    track = create :track
    user = create :user

    Metric::Create.stubs(:defer).raises

    perform_enqueued_jobs do
      Metric::Queue.(type, occurred_at, track:, user:, issue:, request_context: Exercism.request_context)
    end

    refute Metric.exists?
  end
end
