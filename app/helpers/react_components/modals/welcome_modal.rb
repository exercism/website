module ReactComponents
  module Modals
    class WelcomeModal < ReactComponent
      def to_s
        return if current_user.introducer_dismissed?(slug)

        if current_user.solutions.count >= 2
          current_user.dismiss_introducer!(slug)
          return
        end

        super(
          "modals-welcome-modal",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug)
          }
        )
      end

      private
      def slug
        "welcome-modal"
      end
    end
  end
end
