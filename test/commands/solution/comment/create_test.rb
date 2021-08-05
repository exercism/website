require "test_helper"

class Solution::Comment::CreateTest < ActiveSupport::TestCase
  test "creates normally" do
    user = create :user
    solution = create :practice_solution
    markdown = "foo\n\nbar"

    comment = Solution::Comment::Create.(user, solution, markdown)

    assert_equal user, comment.author
    assert_equal solution, comment.solution
    assert_equal markdown, comment.content_markdown
    assert_equal "<p>foo</p>\n<p>bar</p>\n", comment.content_html
  end
end
