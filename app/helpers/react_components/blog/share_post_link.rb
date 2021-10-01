module ReactComponents
  module Blog
    class SharePostLink < ReactComponent
      initialize_with :params

      def to_s
        super("blog-share-post-link", params)
      end
    end
  end
end
