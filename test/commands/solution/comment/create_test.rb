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

  test "increments num_comments on solution" do
    user = create :user
    solution = create :practice_solution

    Solution::Comment::Create.(user, solution, "first comment")
    assert_equal 1, solution.num_comments

    Solution::Comment::Create.(user, solution, "second comment")
    assert_equal 2, solution.num_comments
  end
end
