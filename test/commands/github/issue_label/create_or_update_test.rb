require "test_helper"

class Github::IssueLabel::CreateOrUpdateTest < ActiveSupport::TestCase
  test "create issue label" do
    issue = create :github_issue
    label = "help-wanted"

    review = Github::IssueLabel::CreateOrUpdate.(issue, label)

    assert_equal issue, review.issue
    assert_equal label, review.label
  end
end
