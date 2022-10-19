module ReactComponents
  module Community
    class VideoList < ReactComponent
      def to_s
        super("community-video-list", {})
      end
    end
  end
end
