module ReactComponents
  module Modals
    class TrackWelcomeModal < ReactComponent
      initialize_with :track
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-#{slug}",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug),
            track:
          }
        )
      end

      private
      def slug = "track-welcome-modal"
    end
  end
end
