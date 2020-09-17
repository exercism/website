class MaintainingIterationsSummaryTable < ViewComponent
  def render(iterations)
    react_component("maintaining-iterations-summary-table", {
                      iterations: iterations.map(&:serialized)
                    })
  end
end
