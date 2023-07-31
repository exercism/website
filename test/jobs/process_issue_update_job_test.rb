require "test_helper"

class ProcessIssueUpdateJobTest < ActiveJob::TestCase
  non_deleted_actions = %w[opened edited closed reopened labeled unlabeled transferred]
  non_deleted_actions.each do |action|
    test "creates issue record when action is #{action}" do
      ProcessIssueUpdateJob.perform_now(
        action:,
        node_id: "MDU6SXNzdWU3MjM2MjUwMTI=",
        html_url: 'https://github.com/exercism/ruby/issues/999',
        number: 999,
        title: "grep is failing on Windows",
        state: "OPEN",
        repo: "exercism/ruby",
        labels: %w[bug good-first-issue],
        opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
        opened_by_username: "SleeplessByte"
      )

      issue = Github::Issue.find_by(node_id: "MDU6SXNzdWU3MjM2MjUwMTI=")
      assert_equal "MDU6SXNzdWU3MjM2MjUwMTI=", issue.node_id
      assert_equal 999, issue.number
      assert_equal "grep is failing on Windows", issue.title
      assert_equal "exercism/ruby", issue.repo
      assert_equal :open, issue.status
      assert_equal %w[bug good-first-issue], issue.labels.pluck(:name)
      assert_equal Time.parse("2020-10-17T02:39:37Z").utc, issue.opened_at
      assert_equal "SleeplessByte", issue.opened_by_username
    end
  end

  test "deletes issue record and labels when action is deleted" do
    issue = create :github_issue, node_id: "MDU6SXNzdWU3MjM2MjUwMTI="
    create(:github_issue_label, issue:)

    ProcessIssueUpdateJob.perform_now(
      action: "deleted",
      node_id: issue.node_id,
      html_url: issue.github_url,
      number: issue.number,
      title: issue.title,
      state: "OPEN",
      repo: issue.repo,
      labels: issue.labels.pluck(:name),
      opened_at: issue.opened_at,
      opened_by_username: issue.opened_by_username
    )

    refute Github::Issue.where(node_id: "MDU6SXNzdWU3MjM2MjUwMTI=").any?
  end

  %w[opened edited reopened labeled unlabeled transferred].each do |action|
    test "creates task record when action is #{action}" do
      ProcessIssueUpdateJob.perform_now(
        action: "opened",
        node_id: "MDU6SXNzdWU3MjM2MjUwMTI=",
        html_url: 'https://github.com/exercism/ruby/issues/999',
        number: 999,
        title: "grep is failing on Windows",
        state: "OPEN",
        repo: "exercism/ruby",
        labels: ['bug', 'good-first-issue', 'x:action/fix'],
        opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
        opened_by_username: "SleeplessByte"
      )

      task = Github::Task.find_by(issue_url: 'https://github.com/exercism/ruby/issues/999')
      task.issue_url = 'https://github.com/exercism/ruby/issues/999'
    end
  end

  test "deletes task record and labels when action is deleted" do
    issue = create :github_issue, node_id: "MDU6SXNzdWU3MjM2MjUwMTI="
    create :github_task, issue_url: issue.github_url

    ProcessIssueUpdateJob.perform_now(
      action: "deleted",
      node_id: issue.node_id,
      html_url: issue.github_url,
      number: issue.number,
      title: issue.title,
      state: "OPEN",
      repo: issue.repo,
      labels: issue.labels.pluck(:name),
      opened_at: issue.opened_at,
      opened_by_username: issue.opened_by_username
    )

    refute Github::Task.where(issue_url: issue.github_url).any?
  end
end
