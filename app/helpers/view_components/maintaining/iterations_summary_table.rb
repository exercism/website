module ViewComponents
  module Maintaining
    class IterationsSummaryTable < ViewComponent
      initialize_with :iterations

      def to_s
        react_component("maintaining-iterations-summary-table", {
                          iterations: iterations.map(&:serialized)
                        })
      end
    end
  end
end
