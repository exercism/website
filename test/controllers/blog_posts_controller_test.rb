require "test_helper"

class BlogPostsControllerTest < ActionDispatch::IntegrationTest
  test "rss feed is in english by default" do
    TestHelpers.use_blog_test_repo!
    create :blog_post

    get blog_posts_path(format: :rss)

    assert_response :ok
    assert_includes response.body, "<language>en-US</language>"
    assert_includes response.body, "<title>Exercism&#39;s Blog</title>"
  end

  test "rss feed is in the page's locale" do
    TestHelpers.use_blog_test_repo!
    create :blog_post, slug: "sorry-for-the-wait", title: "Sorry for the wait"
    rss = { title: "Az Exercism blogja", description: "Leírás" }

    with_published_translations(hu: { backend: { blog_posts: { index: { rss: } } } }) do
      publish_translated_metadata!(:hu, "blog", {
        "post:sorry-for-the-wait:title" => "Bocs a várakozásért",
        "post:sorry-for-the-wait:marketing_copy" => "Olvasd el"
      })

      get "/hu/blog.rss"
    end

    assert_response :ok
    assert_includes response.body, "<language>hu</language>"
    assert_includes response.body, "<title>Az Exercism blogja</title>"
    assert_includes response.body, "<description>Leírás</description>"
    assert_includes response.body, "<title>Bocs a várakozásért</title>"
  end
end
