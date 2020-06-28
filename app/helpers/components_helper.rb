module ComponentsHelper
  def iterations_summary_table(solution)
    react_component("iterations-summary-table", {
                      solution_id: solution.id,
                      iterations: solution.serialized_iterations
                    })
  end

  private
  def react_component(id, data)
    tag :div, {
      "data-react-#{id}": true,
      "data-react-data": data.to_json
    }
  end
end
