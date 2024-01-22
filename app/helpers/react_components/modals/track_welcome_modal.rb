module ReactComponents
  module Modals
    class TrackWelcomeModal < ReactComponent
      initialize_with :track

      def to_s
        return if current_user.introducer_dismissed?(introducer_slug) || UserTrack.for(current_user,
          track).tutorial_exercise_completed?

        super(
          "modals-#{modal_slug}",
          {
            links: {
              hide_modal: Exercism::Routes.hide_api_settings_introducer_path(introducer_slug),
              activate_practice_mode: Exercism::Routes.activate_practice_mode_api_track_url(track),
              activate_learning_mode: Exercism::Routes.activate_learning_mode_api_track_url(track),
              edit_hello_world: Exercism::Routes.edit_track_exercise_path(track, 'hello-world'),
              cli_walkthrough: Exercism::Routes.cli_walkthrough_path,
              track_tooling: Exercism::Routes.track_doc_path(track, 'installation'),
              learning_resources: Exercism::Routes.track_doc_path(track, 'learning'),
              download_cmd: Exercise.for(track.slug, 'hello-world').download_cmd
            },
            track:
          }
        )
      end

      private
      def modal_slug = "track-welcome-modal"
      def introducer_slug = "track-welcome-modal-#{track.slug}"
    end
  end
end
