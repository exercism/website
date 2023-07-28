require "test_helper"

class Github::Task::SyncRepoTest < ActiveSupport::TestCase
  test "creates task if issue is opened and not claimed" do
    issue = create :github_issue, status: :open
    create(:github_issue_label, name: 'x:action/fix', issue:)

    task = Github::Task::SyncTask.(issue)

    assert_equal issue.github_url, task.issue_url
    assert_equal issue.repo, task.repo
    assert_equal issue.title, task.title
    assert_equal issue.opened_at, task.opened_at
    assert_equal issue.opened_by_username, task.opened_by_username
    assert_equal :fix, task.action
    assert_nil task.knowledge
    assert_nil task.area
    assert_nil task.size
    assert_nil task.type
  end

  test "set task properties based on labels" do
    issue = create :github_issue, status: :open
    create :github_issue_label, issue:, name: 'x:action/fix'
    create :github_issue_label, issue:, name: 'x:knowledge/intermediate'
    create :github_issue_label, issue:, name: 'x:module/analyzer'
    create :github_issue_label, issue:, name: 'x:size/medium'
    create :github_issue_label, issue:, name: 'x:type/coding'

    task = Github::Task::SyncTask.(issue)

    assert_equal :fix, task.action
    assert_equal :intermediate, task.knowledge
    assert_equal :analyzer, task.area
    assert_equal :medium, task.size
    assert_equal :coding, task.type
  end

  test "updates task if task exists and issue is opened and not claimed" do
    issue = create :github_issue, status: :open
    create :github_issue_label, issue:, name: 'x:action/fix'
    create :github_issue_label, issue:, name: 'x:knowledge/intermediate'
    create :github_issue_label, issue:, name: 'x:module/analyzer'
    create :github_issue_label, issue:, name: 'x:size/medium'
    create :github_issue_label, issue:, name: 'x:type/coding'

    task = create :github_task, issue_url: issue.github_url, repo: issue.repo, title: issue.title,
      opened_at: issue.opened_at, opened_by_username: issue.opened_by_username,
      action: :proofread, knowledge: :none, area: :representer, size: :large, type: :docs

    issue.update!(
      title: 'Improve CI speed',
      opened_at: Time.parse('2020-10-17T02:39:37Z').utc,
      opened_by_username: 'SleeplessByte'
    )

    Github::Task::SyncTask.(issue)

    task.reload
    assert_equal 'Improve CI speed', task.title
    assert_equal Time.parse('2020-10-17T02:39:37Z').utc, task.opened_at
    assert_equal 'SleeplessByte', task.opened_by_username
    assert_equal :fix, task.action
    assert_equal :intermediate, task.knowledge
    assert_equal :analyzer, task.area
    assert_equal :medium, task.size
    assert_equal :coding, task.type
  end

  test "does not create task if issue is closed" do
    issue = create :github_issue, status: :closed

    Github::Task::SyncTask.(issue)

    assert_empty Github::Task.all
  end

  test "destroys task if issue is closed" do
    issue = create :github_issue, status: :closed
    create :github_task, issue_url: issue.github_url

    Github::Task::SyncTask.(issue)

    assert_empty Github::Task.all
  end

  test "does not create task if issue has claimed label" do
    issue = create :github_issue, status: :closed
    create :github_issue_label, issue:, name: 'x:status/claimed'

    Github::Task::SyncTask.(issue)

    assert_empty Github::Task.all
  end

  test "destroys task if issue has claimed label" do
    issue = create :github_issue, status: :closed
    create :github_issue_label, issue:, name: 'x:status/claimed'
    create :github_task, issue_url: issue.github_url

    Github::Task::SyncTask.(issue)

    assert_empty Github::Task.all
  end

  test "does not create task if issue does not have any label" do
    issue = create :github_issue, status: :open

    Github::Task::SyncTask.(issue)

    assert_empty Github::Task.all
  end

  test "does not create task if issue does not have at least one exercism label" do
    issue = create :github_issue, status: :open
    create(:github_issue_label, name: 'good first issue', issue:)

    Github::Task::SyncTask.(issue)

    assert_empty Github::Task.all
  end
end
