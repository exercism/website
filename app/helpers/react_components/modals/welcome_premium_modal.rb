module ReactComponents
  module Modals
    class WelcomePremiumModal < ReactComponent
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-welcome-premium-modal",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug)
          }
        )
      end

      private
      def slug
        "welcome-premium-modal"
      end
    end
  end
end
