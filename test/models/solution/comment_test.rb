require "test_helper"

class Solution::CommentTest < ActiveSupport::TestCase
  test "author works correctly" do
    comment = create :solution_comment
    assert_equal [comment], comment.reload.author.solution_comments
  end
end
