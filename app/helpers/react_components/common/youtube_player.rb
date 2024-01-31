module ReactComponents
  module Common
    class YoutubePlayer < ReactComponent
      initialize_with :id

      def to_s
        super("common-youtube-player", {
          id:,
          mark_as_seen_endpoint:
        })
      end

      def mark_as_seen_endpoint
        return nil unless user_signed_in?
        return nil if current_user.watched_video?(:youtube, id)

        Exercism::Routes.api_watched_videos_path(video_provider: :youtube, video_id: id)
      end
    end
  end
end
