module ReactComponents
  module Track
    class IterationSummary < ReactComponent
      def initialize(iteration, slim: false)
        super()

        @iteration = iteration
        @slim = slim
      end

      def to_s
        super(
          "track-iteration-summary", {
            iteration: SerializeIteration.(iteration),
            class_name: slim ? "--slim" : nil
          },
          wrapper_class_modifier: slim ? "slim" : nil
        )
      end

      private
      attr_reader :iteration, :slim
    end
  end
end
