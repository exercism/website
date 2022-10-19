module ReactComponents
  module Community
    class VideoList < ReactComponent
      def to_s
        # TODO: replace tracks with a track_request
        super("community-video-list", { tracks: AssembleTracksForSelect.() })
      end
    end
  end
end
