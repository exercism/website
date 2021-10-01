module ViewComponents
  module Blog
    class SharePostButton < ViewComponent
      def self.platforms
        ReactComponents::Common::ShareButton.platforms
      end

      def initialize(post, platforms = self.class.platforms)
        @post = post
        @platforms = platforms

        super()
      end

      def to_s
        ReactComponents::Common::ShareButton.new(
          {
            title: "Share this blog post",
            share_title: post.title,
            share_link: Exercism::Routes.blog_post_url(post)
          },
          platforms
        ).to_s
      end

      private
      attr_reader :post, :platforms
    end
  end
end
