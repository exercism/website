require_relative "../react_component_test_case"

class ReactComponents::Impact::MapTest < ReactComponentTestCase
  test "renders the recent start solution metrics" do
    metric = create :start_solution_metric

    assert_equal [metric.id], rendered_metric_ids(ReactComponents::Impact::Map.new)
  end

  test "renders metrics whose solution has been deleted" do
    deleted = create :start_solution_metric
    deleted.solution.delete
    kept = create :start_solution_metric

    assert_equal [deleted.id, kept.id], rendered_metric_ids(ReactComponents::Impact::Map.new)
  end

  private
  def rendered_metric_ids(component)
    data = Nokogiri::HTML(component.to_s).at_css("[data-react-data]")["data-react-data"]
    JSON.parse(data)["metrics"].map { |metric| metric["id"] }
  end
end
