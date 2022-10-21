require 'test_helper'

module Git
  class BlogTest < ActiveSupport::TestCase
    setup do
      TestHelpers.use_blog_test_repo!
    end

    test "post_content" do
      expected = "This is some great blog content\nFTW!!\n"
      actual = Git::Blog.post_content_for('sorry-for-the-wait')
      assert_equal expected, actual
    end

    test "story_content" do
      expected = "Because it's great!\n"
      actual = Git::Blog.story_content_for('why-i-love-tech')
      assert_equal expected, actual
    end
  end
end
