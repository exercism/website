module ReactComponents
  module Common
    class ShareButton < ReactComponent
      def self.platforms
        %i[facebook twitter reddit linkedin devto]
      end

      initialize_with :params

      def to_s
        super("common-share-button", {
          title: params[:title],
          share_title: params[:share_title],
          share_link: params[:share_link],
          platforms: params[:platforms] || self.class.platforms
        })
      end
    end
  end
end
