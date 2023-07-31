require "test_helper"

class Github::IssueTest < ActiveSupport::TestCase
  test "labels" do
    issue = create :github_issue
    label_1 = create :github_issue_label, issue:, name: 'help-wanted'
    label_2 = create :github_issue_label, issue:, name: 'good-first-issue'
    label_3 = create :github_issue_label, :random

    assert_includes issue.labels, label_1
    assert_includes issue.labels, label_2
    refute_includes issue.labels, label_3
  end

  test "status_open?" do
    issue = create :github_issue, status: :open

    assert issue.status_open?
    refute issue.status_closed?
  end

  test "status_open!" do
    issue = create :github_issue, status: :closed

    issue.status_open!

    assert issue.status_open?
    refute issue.status_closed?
  end

  test "status_closed?" do
    issue = create :github_issue, status: :closed

    refute issue.status_open?
    assert issue.status_closed?
  end

  test "status_closed!" do
    issue = create :github_issue, status: :open

    issue.status_closed!

    refute issue.status_open?
    assert issue.status_closed?
  end

  test "issue_url" do
    issue = create :github_issue, repo: 'exercism/fsharp', number: 32

    assert_equal 'https://github.com/exercism/fsharp/issues/32', issue.github_url
  end
end
