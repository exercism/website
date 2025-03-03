require 'test_helper'

class Bootcamp::CustomFunction::BuildRecursiveListTest < ActiveSupport::TestCase
  test "returns basic list" do
    user = create :user
    fn_1 = create :bootcamp_custom_function, user:, active: true
    fn_2 = create :bootcamp_custom_function, user:, active: true

    list = Bootcamp::CustomFunction::BuildRecursiveList.(user, [fn_1.name, fn_2.name])
    assert_equal([fn_1.name, fn_2.name], list.map { |li| li[:name] })
  end

  test "returns recursive list" do
    user = create :user
    fn_1 = create :bootcamp_custom_function, user:, active: true
    create :bootcamp_custom_function, user:, active: true
    fn_3 = create :bootcamp_custom_function, user:, active: true
    fn_4 = create :bootcamp_custom_function, user:, active: true, depends_on: [fn_3.name]
    fn_5 = create :bootcamp_custom_function, user:, active: true, depends_on: [fn_4.name]

    list = Bootcamp::CustomFunction::BuildRecursiveList.(user, [fn_1.name, fn_5.name])
    assert_equal([fn_1, fn_3, fn_4, fn_5].map(&:name), list.map { |li| li[:name] })
  end
end
