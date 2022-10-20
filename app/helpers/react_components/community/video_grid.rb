module ReactComponents
  module Community
    class VideoGrid < ReactComponent
      def to_s
        # TODO: replace tracks with a track_request
        super("community-video-grid", { tracks: AssembleTracksForSelect.() })
      end
    end
  end
end
