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
        Metric.last(40)
      end
    end
  end
end
