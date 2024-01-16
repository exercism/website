module ReactComponents
  module Track
    class ActivatePracticeMode < ReactComponent
      initialize_with :track, :button_label, redirect_to_url: nil

      def to_s
        super("track-activate-practice-mode", {
          endpoint: Exercism::Routes.activate_practice_mode_api_track_url(track),
          button_label:,
          redirect_to_url:
        })
      end
    end
  end
end
