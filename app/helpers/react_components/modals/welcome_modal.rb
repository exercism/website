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
            num_tracks: ::Track.active.count,
            links: {
              hide_modal_endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug),
              api_user_endpoint: Exercism::Routes.api_user_url
            }
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
