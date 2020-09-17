class ExampleIterationsSummaryTable < ViewComponent
  def render(solution)
    react_component("example-iterations-summary-table", {
                      solution_id: solution.id,
                      iterations: solution.serialized_iterations
                    })
  end
end
