class SerializeBlogPostForSharing
  include Mandate

  initialize_with :blog_post

  def call
    {
      title: "Share this blog post",
      share_title: blog_post.title,
      share_link: Exercism::Routes.blog_post_url(blog_post)
    }
  end
end
