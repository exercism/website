require_relative "../view_component_test_case"

module Student
  class ConceptsMapTest < ViewComponentTestCase
    test "component with empty concepts map rendered correctly" do
      data = {
        concepts: [],
        layout: [],
        connections: []
      }
      component = ViewComponents::Student::ConceptsMap.new(data).to_s

      assert_component_equal component, "concepts-map", { graph: data }
    end
  end
end
