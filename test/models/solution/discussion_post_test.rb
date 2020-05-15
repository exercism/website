require 'test_helper'

class Solution::DiscussionPostTest < ActiveSupport::TestCase
  test "validates content markdown" do
    post = build :solution_discussion_post
    assert post.valid?

    post.content_markdown = " "
    refute post.valid?
   end
end
