module ReactComponents
  module Track
    class IterationSummary < ReactComponent
      initialize_with :iteration

      def to_s
        super("track-iteration-summary", { iteration: SerializeIteration.(iteration) })
      end
    end
  end
end
