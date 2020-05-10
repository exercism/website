require 'test_helper'

class SolutionTest < ActiveSupport::TestCase
  test "sets uuid" do
    solution = build :concept_solution, uuid: nil
    assert_nil solution.uuid
    solution.save!
    refute solution.uuid.nil?
  end

  test "doesn't override uuid" do
    uuid = "foobar"
    solution = build :concept_solution, uuid: uuid
    assert_equal uuid, solution.uuid
    solution.save!
    assert_equal uuid, solution.uuid
  end
end
