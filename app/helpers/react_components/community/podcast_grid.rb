module ReactComponents
  module Community
    class PodcastGrid < ReactComponent
      def to_s
        # TODO: replace tracks with a track_request
        super("community-podcast-grid", { tracks: AssembleTracksForSelect.() })
      end
    end
  end
end
