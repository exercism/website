module ReactComponents
  module Common
    class YoutubePlayer < ReactComponent
      initialize_with :id

      def to_s
        super("common-youtube-player", {
          id:,
          mark_as_seen_endpoint: api_watched_videos_path(:youtube, id)
        })
      end
    end
  end
end
