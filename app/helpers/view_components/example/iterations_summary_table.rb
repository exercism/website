module ViewComponents
  module Example
    class IterationsSummaryTable < ViewComponent
      initialize_with :solution

      def to_s
        react_component("example-iterations-summary-table", {
                          solution_id: solution.id,
                          iterations: solution.serialized_iterations
                        })
      end
    end
  end
end
