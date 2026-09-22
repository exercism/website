class SerializeBlogPostForSharing
  include Mandate

  initialize_with :blog_post

  def call
    {
      title: I18n.t("components.blog_post.share_title"),
      share_title: blog_post.title,
      share_link: Exercism::Routes.blog_post_url(blog_post)
    }
  end
end
