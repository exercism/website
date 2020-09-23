module ViewComponents
  class MaintainingIterationsSummaryTable < ViewComponent
    initialize_with :iterations

    def to_s
      react_component("maintaining-iterations-summary-table", {
                        iterations: iterations.map(&:serialized)
                      })
    end
  end
end
