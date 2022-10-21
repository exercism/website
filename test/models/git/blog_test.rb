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
  end
end
