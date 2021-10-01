module ReactComponents
  module Common
    class ShareButton < ReactComponent
      initialize_with :platforms, :params

      def self.platforms
        %i[facebook twitter reddit linkedin devto]
      end

      def initialize(params, platforms = self.class.platforms)
        @params = params
        @platforms = platforms

        super()
      end

      def to_s
        super("common-share-button", {
          title: params[:title],
          share_title: params[:share_title],
          share_link: params[:share_link],
          platforms: platforms
        })
      end

      private
      attr_reader :params, :platforms
    end
  end
end
