require_relative "../view_component_test_case"

module Student
  class ConceptMapTest < ViewComponentTestCase
    test "component with empty concepts map rendered correctly" do
      data = {
        concepts: [],
        levels: [],
        connections: [],
        status: []
      }
      component = ViewComponents::Student::ConceptMap.new(data).to_s

      assert_component component, "concept-map", { graph: data }
    end
  end
end
