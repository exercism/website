module ReactComponents
  module Impact
    class Map < ReactComponent
      def to_s
        super(
          "impact-map",
          {
            metrics: metrics.map(&:to_broadcast_hash)
          }
        )
      end

      private
      def metrics
        Metrics::StartSolutionMetric.last(10)
      end
    end
  end
end
