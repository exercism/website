require "test_helper"

class Github::IssueLabel::CreateOrUpdateTest < ActiveSupport::TestCase
  test "create issue label" do
    issue = create :github_issue
    name = "help-wanted"

    issue_label = Github::IssueLabel::CreateOrUpdate.(issue, name)

    assert_equal issue, issue_label.issue
    assert_equal name, issue_label.name
  end
end
