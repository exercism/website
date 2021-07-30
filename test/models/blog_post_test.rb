require "test_helper"

class BlogPostTest < ActiveSupport::TestCase
  test "published and scheduled scopes" do
    freeze_time do
      post_1 = create :blog_post, published_at: Time.current - 1.second
      post_2 = create :blog_post, published_at: Time.current + 1.second
      post_3 = create :blog_post, published_at: Time.current

      assert_equal [post_1, post_3], BlogPost.published
      assert_equal [post_2], BlogPost.scheduled
      assert_equal [post_2, post_3, post_1], BlogPost.ordered_by_recency
    end
  end

  test "to_param" do
    post = create(:blog_post)
    assert_equal post.slug, post.to_param
  end

  test "video?" do
    post = create(:blog_post)
    refute post.video?

    post.update(youtube_url: "foo")
    assert post.video?
  end

  test "content " do
    TestHelpers.use_blog_test_repo!
    expected = "<p>This is some great blog content\nFTW!!</p>\n"
    assert_equal expected, create(:blog_post).content
  end
end
