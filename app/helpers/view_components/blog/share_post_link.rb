module ViewComponents
  module Blog
    class SharePostLink < ViewComponent
      def self.platforms
        ReactComponents::Common::ShareButton.platforms
      end

      def initialize(post, platforms = self.class.platforms)
        @post = post
        @platforms = platforms

        super()
      end

      def to_s
        ReactComponents::Blog::SharePostLink.new(AssembleBlogPostSharePanel.(post, platforms)).to_s
      end

      private
      attr_reader :post, :platforms
    end
  end
end
