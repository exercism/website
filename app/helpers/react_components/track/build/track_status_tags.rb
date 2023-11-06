module ReactComponents
  module Track
    class Build::TrackStatusTags < ReactComponent
      def to_s
        super("track-build-track-status-tags", {})
      end
    end
  end
end
