require "test_helper"

class BlogPostTest < ActiveSupport::TestCase
  test "published and scheduled scopes" do
    freeze_time do
      post_1 = create :blog_post, :random_slug, published_at: Time.current - 1.second
      post_2 = create :blog_post, :random_slug, published_at: Time.current + 1.second
      post_3 = create :blog_post, :random_slug, published_at: Time.current

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

    post.update(youtube_id: "foo")
    assert post.video?
  end

  test "content_html" do
    TestHelpers.use_blog_test_repo!
    expected = "<p>This is some great blog content\nFTW!!</p>\n"
    assert_equal expected, create(:blog_post).content_html
  end

  test "image_url for asset host that is domain" do
    Rails.application.config.action_controller.expects(:asset_host).returns('http://test.exercism.org').at_least_once
    blog_post = create :blog_post, image_url: nil

    assert_equal "http://test.exercism.org/assets/graphics/blog-placeholder-article-242f2203f76126e572ded5bd56d8d7942e0475cf.svg",
      blog_post.image_url
  end

  test "image_url for asset host that is path" do
    Rails.application.config.action_controller.expects(:asset_host).returns('/my-assets').at_least_once
    blog_post = create :blog_post, image_url: nil

    assert_equal "/my-assets/assets/graphics/blog-placeholder-article-242f2203f76126e572ded5bd56d8d7942e0475cf.svg",
      blog_post.image_url
  end
end
