module ReactComponents
  module Modals
    class WelcomeInsidersModal < ReactComponent
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-welcome-insiders-modal",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug)
          }
        )
      end

      private
      def slug
        "welcome-insiders-modal"
      end
    end
  end
end
