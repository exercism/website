class MaintainingIterationsSummaryTable < ViewComponent
  include Mandate

  initialize_with :iterations

  def to_s
    react_component("maintaining-iterations-summary-table", {
                      iterations: iterations.map(&:serialized)
                    })
  end
end
