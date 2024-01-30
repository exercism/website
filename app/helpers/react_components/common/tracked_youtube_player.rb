module ReactComponents
  module Common
    class TrackedYoutubePlayer < ReactComponent
      initialize_with :exercise

      def to_s
        super("common-tracked-youtube-player", {
          deep_dive_youtube_id: exercise.deep_dive_youtube_id,
          # TODO: add endpoint
          mark_as_seen_endpoint: ''
        })
      end
    end
  end
end
