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

      # TODO: Question: What is the second argument of this function supposed to be?
      #   A hash representing the html structure?
      assert_component_equal component,
        { id: "concepts-map", props: { data: data } }
    end
  end
end
