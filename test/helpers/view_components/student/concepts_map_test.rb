require_relative "../view_component_test_case"

module Student
  class ConceptsMapTest < ViewComponentTestCase
    test "component with empty concepts map rendered correctly" do
      data = {
        concepts: [],
        levels: [],
        connections: []
      }
      component = ViewComponents::Student::ConceptsMap.new(data).to_s

      assert_component component, "concepts-map", { graph: data }
    end
  end
end
