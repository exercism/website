module ViewComponents
  module Blog
    class SharePostButton < ViewComponent
      initialize_with :post

      def to_s
        ReactComponents::Common::ShareButton.new(AssembleBlogPostSharePanel.(post)).to_s
      end
    end
  end
end
