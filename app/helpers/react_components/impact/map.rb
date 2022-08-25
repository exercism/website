module ReactComponents
  module Impact
    class Map < ReactComponent
      initialize_with :metrics

      def to_s
        super(
          "impact-map",
          {
            metrics: metrics.map(&:to_broadcast_hash)
          }
        )
      end
    end
  end
end
