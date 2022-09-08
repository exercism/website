module ReactComponents
  module Impact
    class Rocket < ReactComponent
      initialize_with :metrics

      def to_s
        super(
          "impact-become-fuel",
          {
            metrics: metrics.map(&:to_broadcast_hash)
          }
        )
      end
    end
  end
end
