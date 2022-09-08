module ReactComponents
  module Impact
    class Chart < ReactComponent
      initialize_with :metrics

      def to_s
        super(
          "impact-chart",
          {
            metrics: metrics.map(&:to_broadcast_hash)
          }
        )
      end
    end
  end
end
