require_relative "../view_component_test_case"

class Student::ConceptsMapTest < ViewComponentTestCase
  test "component rendered correctly" do
    data = { concepts: [], layout: [], connections: [] }
    assert_component_equal ViewComponents::Student::ConceptsMap.new(data).to_s,
      { id: "concepts-map", props: { data: data } }
  end
end
