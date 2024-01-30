module ReactComponents
  module Common
    class YoutubePlayer < ReactComponent
      def initialize(youtube_id)
        super()

        Rails.logger.debug "YUTUB DUBUGU: #{youtube_id.inspect}"

        @youtube_id = youtube_id
      end

      def to_s
        super("common-youtube-player", {
          deep_dive_youtube_id: @youtube_id,
          # TODO: add endpoint
          mark_as_seen_endpoint: ''
        })
      end
    end
  end
end
