require "test_helper"

class Webhooks::ProcessIssueUpdateTest < ActiveSupport::TestCase
  valid_actions = %w[opened edited deleted closed reopened labeled unlabeled transferred]
  valid_actions.each do |action|
    test "should enqueue process issue update job when action is #{action}" do
      assert_enqueued_jobs 1, only: ProcessIssueUpdateJob do
        Webhooks::ProcessIssueUpdate.(
          action:,
          node_id: "MDU6SXNzdWU3MjM2MjUwMTI=",
          number: 999,
          title: "grep is failing on Windows",
          state: "OPEN",
          repo: "exercism/ruby",
          labels: %w[bug good-first-issue],
          opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
          opened_by_username: "SleeplessByte"
        )
      end
    end
  end

  invalid_actions = %w[pinned unpinned assigned unassigned locked milestoned demilestoned]
  invalid_actions.each do |action|
    test "should not enqueue process issue update job when action is #{action}" do
      assert_no_enqueued_jobs only: ProcessIssueUpdateJob do
        Webhooks::ProcessIssueUpdate.(
          action:,
          node_id: "MDU6SXNzdWU3MjM2MjUwMTI=",
          number: 999,
          title: "grep is failing on Windows",
          state: "OPEN",
          repo: "exercism/ruby",
          labels: %w[bug good-first-issue],
          opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
          opened_by_username: "SleeplessByte"
        )
      end
    end
  end
end
