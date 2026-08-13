require "test_helper"

class Solution::Comment::UpdateTest < ActiveSupport::TestCase
  test "updates the content and returns true" do
    comment = create :solution_comment, content_markdown: "old"

    assert Solution::Comment::Update.(comment, "new\n\ncontent")

    comment.reload
    assert_equal "new\n\ncontent", comment.content_markdown
    assert_equal "<p>new</p>\n<p>content</p>\n", comment.content_html
  end

  test "invalidates the cloudflare cache" do
    comment = create :solution_comment

    Solution::InvalidateCloudflareCache.expects(:defer).with(comment.solution)

    Solution::Comment::Update.(comment, "new content")
  end

  test "returns false and does not invalidate when invalid" do
    comment = create :solution_comment, content_markdown: "old"

    Solution::InvalidateCloudflareCache.expects(:defer).never

    refute Solution::Comment::Update.(comment, "")
    assert_equal "old", comment.reload.content_markdown
  end
end
