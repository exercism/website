module ViewComponents
  module Blog
    class SharePostLink < ViewComponent
      initialize_with :post

      def to_s
        ReactComponents::Blog::SharePostLink.new(AssembleBlogPostSharePanel.(post)).to_s
      end
    end
  end
end
