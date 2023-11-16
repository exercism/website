module ReactComponents
  module Track
    class ActivityTicker < ReactComponent
      initialize_with :track

      def to_s
        super("track-activity-ticker", {
          track_title: track.title
        })
      end
    end
  end
end
