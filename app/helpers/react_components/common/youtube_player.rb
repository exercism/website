module ReactComponents
  module Common
    class YoutubePlayer < ReactComponent
      initialize_with :id

      def to_s
        super("common-youtube-player", {
          id:,
          mark_as_seen_endpoint: Exercism::Routes.api_watched_videos_url(:youtube, id)
        })
      end
    end
  end
end
