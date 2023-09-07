module ReactComponents
  module Impact
    class Map < ReactComponent
      include Mandate

      initialize_with track: nil

      def to_s
        super(
          "impact-map",
          {
            metrics: metrics.map(&:to_broadcast_hash),
            track_title: track&.title
          }
        )
      end

      private
      def metrics
        records = Metrics::StartSolutionMetric.includes(:track)
        records = records.where(track:) if track.present?
        records.last(10)
      end
    end
  end
end
