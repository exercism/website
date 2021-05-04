require "test_helper"

class BugReportTest < ActiveSupport::TestCase
  test "parses markdown to html on save" do
    bug_report = build :problem_report, content_markdown: "Hello"

    bug_report.save

    assert_equal "<p>Hello</p>\n", bug_report.content_html
  end
end
