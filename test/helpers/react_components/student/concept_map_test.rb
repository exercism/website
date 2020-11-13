require_relative "../react_component_test_case"

module Student
  class ConceptMapTest < ReactComponentTestCase
    test "component with empty concepts map rendered correctly" do
      data = {
        concepts: [],
        levels: [],
        connections: [],
        status: []
      }
      component = ReactComponents::Student::ConceptMap.new(data).to_s

      assert_component component, "concept-map", { graph: data }
    end
  end
end
