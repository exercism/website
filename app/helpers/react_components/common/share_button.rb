module ReactComponents
  module Common
    class ShareButton < ReactComponent
      initialize_with :params

      def to_s
        super("common-share-button", {
          title: params[:title],
          share_title: params[:share_title],
          share_link: params[:share_link]
        })
      end
    end
  end
end
