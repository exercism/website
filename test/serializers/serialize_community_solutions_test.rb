require 'test_helper'

class SerializeCommunitySolutionsTest < ActiveSupport::TestCase
  test "basic test" do
    solution = create :concept_solution

    expected = [
      SerializeCommunitySolution.(solution)
    ]

    assert_equal expected, SerializeCommunitySolutions.(
      Solution.all
    )
  end
end
