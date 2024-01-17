module ReactComponents
  module Modals
    class TrackWelcomeModal < ReactComponent
      initialize_with :track
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-#{slug}",
          {
            links: {
              hide_modal: Exercism::Routes.hide_api_settings_introducer_path(slug),
              activate_practice_mode: Exercism::Routes.activate_practice_mode_api_track_url(track),
              activate_learning_mode: Exercism::Routes.activate_learning_mode_api_track_url(track),
              hello_world: Exercism::Routes.track_exercise_path(track, 'hello-world')
            },
            track:
          }
        )
      end

      private
      def slug = "track-welcome-modal"
    end
  end
end
