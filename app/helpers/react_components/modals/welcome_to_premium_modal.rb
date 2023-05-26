module ReactComponents
  module Modals
    class WelcomeToPremiumModal < ReactComponent
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-#{slug}",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug)
          }
        )
      end

      private
      def slug = "welcome-to-premium-modal"
    end
  end
end
