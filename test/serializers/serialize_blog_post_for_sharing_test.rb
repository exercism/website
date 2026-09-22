require "test_helper"

class SerializeBlogPostForSharingTest < ActiveSupport::TestCase
  test "serializes in english" do
    post = create :blog_post, title: "Some blog post"

    expected = {
      title: "Share this blog post",
      share_title: "Some blog post",
      share_link: Exercism::Routes.blog_post_url(post)
    }
    assert_equal expected, SerializeBlogPostForSharing.(post)
  end

  test "serializes in another locale" do
    post = create :blog_post, slug: "hello"
    catalog = { components: { blog_post: { share_title: "Oszd meg ezt a bejegyzést" } } }

    with_published_translations(hu: { backend: catalog }) do
      publish_translated_metadata!(:hu, "blog", { "post:hello:title" => "Szia", "post:hello:marketing_copy" => "Olvasd" })

      I18n.with_locale(:hu) do
        serialized = SerializeBlogPostForSharing.(post)
        assert_equal "Oszd meg ezt a bejegyzést", serialized[:title]
        assert_equal "Szia", serialized[:share_title]
      end
    end
  end
end
