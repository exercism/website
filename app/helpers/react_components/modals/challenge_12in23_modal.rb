module ReactComponents
  module Modals
    class Challenge12in23Modal < ReactComponent
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-challenge-12in23-modal",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug)
          }
        )
      end

      private
      def slug
        "challenge-12in23-modal"
      end
    end
  end
end
