require 'test_helper'

class Bootcamp::CustomFunction::BuildRecursiveListTest < ActiveSupport::TestCase
  test "returns basic list" do
    user = create :user
    fn_1 = create :bootcamp_custom_function, user:, active: true
    fn_2 = create :bootcamp_custom_function, user:, active: true

    actual = Bootcamp::CustomFunction::BuildRecursiveList.(user, [fn_1.name])
    expected = {
      available: [{
        name: fn_1.name,
        dependencies: [],
        selected: true
      }, {
        name: fn_2.name,
        dependencies: [],
        selected: false
      }].sort_by { |fn| fn[:name] },
      for_interpreter: [
        { name: fn_1.name, arity: fn_1.arity, code: fn_1.code, description: fn_1.description },
        { name: fn_2.name, arity: fn_2.arity, code: fn_2.code, description: fn_2.description }
      ].sort_by { |fn| fn[:name] }
    }
    assert_equal expected, actual
  end

  test "returns recursive list" do
    user = create :user
    fn_1 = create :bootcamp_custom_function, user:, active: true, name: "abc"
    fn_2 = create :bootcamp_custom_function, user:, active: true, name: "def"
    fn_3 = create :bootcamp_custom_function, user:, active: true, depends_on: [fn_2.name], name: "ghi"
    fn_4 = create :bootcamp_custom_function, user:, active: true, depends_on: [fn_3.name], name: "jkl"

    create :bootcamp_custom_function, active: true # Differnet user
    create :bootcamp_custom_function, user:, active: false # Inactive

    actual = Bootcamp::CustomFunction::BuildRecursiveList.(user, [fn_1.name, fn_4.name])
    expected = {
      available: [{
        name: fn_1.name,
        dependencies: [],
        selected: true
      }, {
        name: fn_2.name,
        dependencies: [],
        selected: false
      }, {
        name: fn_3.name,
        dependencies: [fn_2.name],
        selected: false
      }, {
        name: fn_4.name,
        dependencies: [fn_2.name, fn_3.name],
        selected: true
      }].sort_by { |fn| fn[:name] },
      for_interpreter: [
        { name: fn_1.name, arity: fn_1.arity, code: fn_1.code, description: fn_1.description },
        { name: fn_2.name, arity: fn_2.arity, code: fn_2.code, description: fn_2.description },
        { name: fn_3.name, arity: fn_3.arity, code: fn_3.code, description: fn_3.description },
        { name: fn_4.name, arity: fn_4.arity, code: fn_4.code, description: fn_4.description }
      ]
    }
    assert_equal expected, actual
  end
end
