require "test_helper"

class Github::IssueTest < ActiveSupport::TestCase
  test "labels" do
    issue = create :github_issue
    label_1 = create :github_issue_label, issue: issue, label: 'help-wanted'
    label_2 = create :github_issue_label, issue: issue, label: 'good-first-issue'
    label_3 = create :github_issue_label, :random

    assert_includes issue.labels, label_1
    assert_includes issue.labels, label_2
    refute_includes issue.labels, label_3
  end

  test "open?" do
    issue = create :github_issue, status: :open

    assert issue.open?
    refute issue.closed?
  end

  test "open!" do
    issue = create :github_issue, status: :closed

    issue.open!

    assert issue.open?
    refute issue.closed?
  end

  test "closed?" do
    issue = create :github_issue, status: :closed

    refute issue.open?
    assert issue.closed?
  end

  test "closed!" do
    issue = create :github_issue, status: :open

    issue.closed!

    refute issue.open?
    assert issue.closed?
  end

  test "open scope" do
    issue_1 = create :github_issue, :random, status: :open
    issue_2 = create :github_issue, :random, status: :open
    create :github_issue, :random, status: :closed

    assert_equal [issue_1, issue_2], Github::Issue.open
  end
end
