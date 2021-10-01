module ReactComponents
  module Blog
    class SharePostLink < ReactComponent
      initialize_with :params

      def to_s
        super("blog-share-post-link", {
          title: params[:title],
          share_title: params[:share_title],
          share_link: params[:share_link],
          platforms: Exercism.share_platforms
        })
      end
    end
  end
end
