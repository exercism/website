module ReactComponents
  module Track
    class ActivatePracticeMode < ReactComponent
      initialize_with :track

      def to_s
        super("track-activate-practice-mode", {
          endpoint: Exercism::Routes.activate_practice_mode_api_track_url(track)
        })
      end
    end
  end
end
