module ReactComponents
  module Common
    class SolutionView < ReactComponent
      initialize_with :solution

      def to_s
        super("common-solution-view", {
          iterations: solution.
            iterations.
            published.
            order(:idx).
            map { |iteration| SerializeIteration.(iteration) },
          language: solution.track.highlightjs_language
        })
      end
    end
  end
end
