module ViewComponents
  module Track
    class IterationSummary < ViewComponent
      initialize_with :iteration

      def to_s
        react_component("track-iteration-summary", { iteration: iteration })
      end
    end
  end
end
