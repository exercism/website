module ReactComponents
  module Common
    class YoutubePlayer < ReactComponent
      def initialize(id)
        super()

        Rails.logger.debug "YUTUB DUBUGU: #{youtube_id.inspect}"

        @youtube_id = id
      end

      def to_s
        super("common-youtube-player", {
          id: @youtube_id,
          # TODO: add endpoint
          mark_as_seen_endpoint:
        })
      end
    end
  end
end
